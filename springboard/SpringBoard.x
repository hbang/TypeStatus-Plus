#import "HBTSPlusPreferences.h"
#import "HBTSPlusAlertController.h"
#import "HBTSPlusBulletinProvider.h"
#import "HBTSPlusServer.h"
#import "HBTSPlusStateHelper.h"
#import "HBTSPlusTapToOpenController.h"
#import "../api/HBTSNotification.h"
#import <AudioToolbox/AudioToolbox.h>
#import <BulletinBoard/BBLocalDataProviderStore.h>
// #import <Cephei/HBStatusBarController.h>
// #import <Cephei/HBStatusBarItem.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <libstatusbar/LSStatusBarItem.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBLockScreenManager.h>
#import <UIKit/UIStatusBarItemView.h>
#import <version.h>

HBTSPlusPreferences *preferences;

LSStatusBarItem *unreadCountStatusBarItem;

extern void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);

#pragma mark - Notification Center

%hook BBLocalDataProviderStore

- (void)loadAllDataProvidersAndPerformMigration:(BOOL)performMigration {
	%orig;

	// add our provider to the in-memory store. it’ll be instantiated for us at some point
	[self _addDataProviderClass:HBTSPlusBulletinProvider.class performMigration:YES];
}

%end

#pragma mark - Unread Count

NSInteger unreadCount = 0;

static inline NSInteger getUnreadCount() {
	SBApplicationController *appController = [%c(SBApplicationController) sharedInstance];

	// get the bundle ids the user wants
	NSArray <NSString *> *apps = preferences.unreadCountApps;
	NSInteger badgeCount = 0;

	for (NSString *bundleIdentifier in apps) {
		// get the SBApplication
		SBApplication *app = [appController applicationWithBundleIdentifier:bundleIdentifier];

		// get the badge count (hopefully an NSNumber) and add it to the count if it’s not zero
		// (hopefully not negative)
		NSNumber *badgeNumber = app.badgeNumberOrString;
		badgeCount += MAX(0, badgeNumber.integerValue);
	}

	// return the final count
	return badgeCount;
}

void updateUnreadCountStatusBarItem() {
	// bail if we don’t have a status bar item (eg, lsb not installed)
	if (!unreadCountStatusBarItem) {
		return;
	}

	// grab the count
	NSInteger newCount = getUnreadCount();

	if (newCount == unreadCount) {
		return;
	}

	unreadCount = newCount;

	// post a notification so apps can get the new count
	[[NSDistributedNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBTSPlusUnreadCountChangedNotification object:nil userInfo:@{
		kHBTSPlusBadgeCountKey: @(unreadCount)
	}]];

	// force an update
	[unreadCountStatusBarItem update];

	// show if we’re enabled and have a non-0 value, hide otherwise
	BOOL enabled = preferences.enabled && preferences.showUnreadCount;
	unreadCountStatusBarItem.visible = enabled && unreadCount > 0;
}

void (^setUpStatusBarItem)(NSNotification *) = ^(NSNotification *nsNotification) {
	// if we have cephei status bar(!) – using %c() for now since it doesn’t have a stable release yet
	// when it does release, libstatusbar support will probably be removed
	/*if (%c(HBStatusBarItem)) {
		HBStatusBarItem *item = [[%c(HBStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatusplus.unreadcount"];
		item.customViewClass = @"HBTSStatusBarUnreadItemView";

		[(HBStatusBarController *)[%c(HBStatusBarController) sharedInstance] addItem:item];

		// cast it to LSStatusBarItem because we only use apis in common from here
		unreadCountStatusBarItem = (LSStatusBarItem *)item;
	} else*/ {
		// try loading libstatusbar
		dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);

		// hmm not loaded? probably not installed. just bail out
		if (!%c(LSStatusBarItem)) {
			return;
		}

		unreadCountStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatusplus.unreadcount" alignment:StatusBarAlignmentRight];
		unreadCountStatusBarItem.imageName = @"TypeStatusPlusUnreadCount";
	}

	// when preferences update (and right now, ugh bad api design sorry), update the status bar item
	[preferences registerPreferenceChangeBlock:^{
		updateUnreadCountStatusBarItem();
	}];
};

%hook FBSSystemService

- (void)setBadgeValue:(id)value forBundleID:(NSString *)bundleID {
	%orig;

	// if this is an app the user wants to be shown in the status bar, have our item updated
	if ([preferences.unreadCountApps containsObject:bundleID]) {
		updateUnreadCountStatusBarItem();
	}
}

%end

#pragma mark - Relay hook

%hook HBTSSpringBoardServer

- (void)receivedRelayedNotification:(NSDictionary *)userInfo {
	%orig;

	// re-post the notification over the distributed center so the messages tweak can see it
	[[NSDistributedNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBTSPlusReceiveRelayNotification object:nil userInfo:userInfo]];
}

%end

#pragma mark - Set status bar notification

void (^receivedSetStatusBarNotification)(NSNotification *) = ^(NSNotification *nsNotification) {
	// not enabled? don’t do anything
	if (!preferences.enabled) {
		return;
	}

	// get the notification type
	HBTSMessageType type = ((NSNumber *)nsNotification.userInfo[kHBTSMessageTypeKey]).unsignedIntegerValue;

	// if it’s an ended notification, there’s nothing else to do
	if (type == HBTSMessageTypeTypingEnded) {
		return;
	}

	// if the user wants vibration, let’s do that
	if ([HBTSPlusStateHelper shouldVibrate]) {
		// TODO: document and define constants for these things
		AudioServicesPlaySystemSoundWithVibration(4095, nil, @{
			@"VibePattern": @[ @YES, @50 ],
			@"Intensity": @1
		});
	}

	// if the user wants an undim, and we aren’t going to show a banner anyway, do that
	// (SBUIUnlockOptionsTurnOnScreenFirstKey doesn’t actually do an unlock… weird stuff)
	if (preferences.wakeWhenLocked) {
		[[%c(SBLockScreenManager) sharedInstance] unlockUIFromSource:0 withOptions:@{
			@"SBUIUnlockOptionsTurnOnScreenFirstKey": @YES,
			@"SBUIUnlockOptionsStartFadeInAnimation": @YES
		}];
	}
};

#pragma mark - Apple weirdness fix

%hook FBSSystemAppProxy

- (void)setKeyboardFocusApplicationWithBundleID:(NSString *)bundleID pid:(pid_t)pid completion:(id)completion {
	// workaround for the keyboard flashing visible for a split second when closing a backgrounded app
	// it seems this only happens when the keyboard focus given to nobody, by passing in nil and 0.
	// when this happens, we’ll instead give focus to springboard
	if (!bundleID) {
		bundleID = @"com.apple.springboard";
		pid = getpid();
	}

	%orig;
}

%end

#pragma mark - Test notification

void sendTestNotification() {
	HBTSNotification *notification = [[HBTSNotification alloc] initWithType:HBTSMessageTypeTyping sender:@"Johnny Appleseed" iconName:@"TypeStatus"];
	notification.sourceBundleID = @"com.apple.MobileSMS";
	[HBTSPlusAlertController sendNotification:notification];
}

#pragma mark - Constructor

%ctor {
	// make sure typestatus free and plus client are loaded before we do anything
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatus.dylib", RTLD_LAZY);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusPlusClient.dylib", RTLD_LAZY);

	// initialise our singleton classes
	[HBTSPlusServer sharedInstance];
	[HBTSPlusTapToOpenController sharedInstance];

	preferences = [%c(HBTSPlusPreferences) sharedInstance];

	// register for test notification notification
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)sendTestNotification, CFSTR("ws.hbang.typestatusplus/TestNotification"), NULL, kNilOptions);

	// register to set up the status bar item when the UIApp loads
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:setUpStatusBarItem];

	// register to do stuff when a set status bar notification is sent by typestatus free
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSClientSetStatusBarNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:receivedSetStatusBarNotification];

	%init;
}
