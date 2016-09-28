#import "HBTSPlusPreferences.h"
#import "HBTSPlusBulletinProvider.h"
#import "HBTSPlusServer.h"
#import "HBTSPlusStateHelper.h"
#import "HBTSPlusTapToOpenController.h"
#import "../api/HBTSNotification.h"
#import <AudioToolbox/AudioToolbox.h>
#import <BulletinBoard/BBLocalDataProviderStore.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <libstatusbar/LSStatusBarItem.h>
#import <libstatusbar/UIStatusBarCustomItem.h>
#import <libstatusbar/UIStatusBarCustomItemView.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBLockScreenManager.h>
#import <UIKit/UIStatusBarItemView.h>
#import <version.h>

HBTSPlusPreferences *preferences;
LSStatusBarItem *unreadCountStatusBarItem;

extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);

#pragma mark - Notification Center

%hook BBLocalDataProviderStore

- (void)loadAllDataProvidersAndPerformMigration:(BOOL)performMigration {
	%orig;
	[self addDataProvider:[HBTSPlusBulletinProvider sharedInstance] performMigration:NO];
}

%end

#pragma mark - Unread Count

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
	%orig;

	if (![%c(HBTSPlusPreferences) sharedInstance].enabled) {
		return;
	}

	// try loading libstatusbar
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);

	// hmm not loaded? probably not installed. just bail out
	if (!%c(LSStatusBarItem)) {
		return;
	}

	unreadCountStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatusplus.unreadcount" alignment:StatusBarAlignmentRight];
	unreadCountStatusBarItem.imageName = @"TypeStatusPlusUnreadCount";
	unreadCountStatusBarItem.visible = YES;
}

%end

%hook SBApplication

- (void)setBadge:(id)badge {
	%orig;

	if ([preferences.unreadCountApps containsObject:self.bundleIdentifier]) {
		[unreadCountStatusBarItem update];
	}
}

%end

%hook HBTSSpringBoardServer

- (void)receivedRelayedNotification:(NSDictionary *)userInfo {
	%orig;

	HBLogDebug(@"received relayed notification");

	[[NSDistributedNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBTSPlusReceiveRelayNotification object:nil userInfo:userInfo]];
}

%end

#pragma mark - Constructor

%ctor {
	// make sure typestatus free is loaded before we do anything
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatus.dylib", RTLD_LAZY);

	// initialise our singleton classes
	[HBTSPlusServer sharedInstance];
	[HBTSPlusTapToOpenController sharedInstance];

	preferences = [%c(HBTSPlusPreferences) sharedInstance];

	// when preferences update, forcefully update the status bar item
	[preferences registerPreferenceChangeBlock:^{
		[unreadCountStatusBarItem update];
	}];

	// when a set status bar notification is sent by typestatus free
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSClientSetStatusBarNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		// not enabled? don’t do anything
		if (!preferences.enabled) {
			return;
		}

		//
		HBTSStatusBarType type = ((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).unsignedIntegerValue;

		if (type == HBTSStatusBarTypeTypingEnded) {
			if ([HBTSPlusStateHelper shouldShowBanner]) {
				[[HBTSPlusBulletinProvider sharedInstance] clearAllBulletins];
			}
		}

		NSString *content = notification.userInfo[kHBTSMessageContentKey];

		// right off the bat, if there’s no title or content, stop right there.
		if (!content || [content isEqualToString:@""]) {
			return;
		}

		// if the user wants vibration, let’s do that
		if ([HBTSPlusStateHelper shouldVibrate]) {
			// TODO: document and define constants for these things
			AudioServicesPlaySystemSoundWithVibration(4095, nil, @{
				@"VibePattern": @[ @YES, @(50) ],
				@"Intensity": @1
			});
		}

		// create a typestatus plus notification object from the user info
		HBTSNotification *receivedNotification = [[HBTSNotification alloc] initWithDictionary:notification.userInfo];

		// if the user wants a banner, let’s do that too
		if ([HBTSPlusStateHelper shouldShowBanner]) {
			// grab this from the notification
			NSString *appIdentifier = receivedNotification.sourceBundleID;

			// if this is a messages notification
			if ([appIdentifier isEqualToString:@"com.apple.MobileSMS"]) {
				// pass it over with the specific logic for messages bulletins
				[[HBTSPlusBulletinProvider sharedInstance] showMessagesBulletinWithContent:content];
			} else {
				// pass over the notification and show it
				[[HBTSPlusBulletinProvider sharedInstance] showBulletinForNotification:receivedNotification];
			}
		}
	}];

	%init;
}
