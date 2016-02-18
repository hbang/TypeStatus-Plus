#import "HBTSPlusBulletinProvider.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <BulletinBoard/BBLocalDataProviderStore.h>
#import <version.h>
#import <AudioToolbox/AudioToolbox.h>
#import "HBTSPlusServer.h"
#import "HBTSPlusTapToOpenController.h"
#import <libstatusbar/LSStatusBarItem.h>
#import <UIKit/UIStatusBarItemView.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import <libstatusbar/UIStatusBarCustomItem.h>
#import <libstatusbar/UIStatusBarCustomItemView.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBLockScreenManager.h>
#import "../HBTSPlusPreferences.h"
#import "HBTSPlusHelper.h"

LSStatusBarItem *unreadCountStatusBarItem;

extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);

#pragma mark - Notification Center

%hook BBLocalDataProviderStore

%group EddyCue
- (void)loadAllDataProvidersAndPerformMigration:(BOOL)performMigration {
	%orig;
	[self addDataProvider:[HBTSPlusBulletinProvider sharedInstance] performMigration:NO];
}
%end

%group CraigFederighi
- (void)loadAllDataProviders {
	%orig;
	[self addDataProvider:[HBTSPlusBulletinProvider sharedInstance]];
}
%end

%end

#pragma mark - Unread Count

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
	%orig;

	if (![[%c(HBTSPlusPreferences) sharedInstance] enabled]) {
		return;
	}

	// is libstatusbar loaded? if not, let's try dlopening it
	if (!%c(LSStatusBarItem)) {
		dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	}

	// still not loaded? probably not installed. just bail out
	if (!%c(LSStatusBarItem)) {
		return;
	}

	unreadCountStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatusplus.unreadcount" alignment:StatusBarAlignmentRight];
	unreadCountStatusBarItem.imageName = @"TypeStatusPlusUnreadCount";
	unreadCountStatusBarItem.visible = YES;
}

%end

%hook SBApplication

- (void)setBadge:(id)arg1 {

	if ([[%c(HBTSPlusPreferences) sharedInstance] enabled] && [self.bundleIdentifier isEqualToString:[[%c(HBTSPlusPreferences) sharedInstance] applicationUsingUnreadCount]]) {
		[unreadCountStatusBarItem update];
	}
	%orig;
}

%end

#pragma mark - Constructor

%ctor {
	[HBTSPlusServer sharedInstance];
	[HBTSPlusTapToOpenController sharedInstance];

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSClientSetStatusBarNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

		if (![[%c(HBTSPlusPreferences) sharedInstance] enabled]) {
			return;
		}

		NSString *content = notification.userInfo[kHBTSMessageContentKey];

		// right off the bat, if there's no title or content, stop right there.
		if (!content || [content isEqualToString:@""]) {
			return;
		}

		if ([HBTSPlusHelper shouldVibrate]) {
			AudioServicesPlaySystemSoundWithVibration(4095, nil, @{
				@"VibePattern": @[ @YES, @(50) ],
				@"Intensity": @1
			});
		}

		if ([HBTSPlusHelper shouldShowBanner]) {
			// this is a hax, probably shouldn't be doing it... ¯\_(ツ)_/¯
			NSString *appIdentifier = [[%c(HBTSPlusTapToOpenController) sharedInstance] appIdentifier] ?: @"com.apple.MobileSMS";

			[[HBTSPlusBulletinProvider sharedInstance] showBulletinWithContent:content appIdentifier:appIdentifier];
		}
	}];

	if (IS_IOS_OR_NEWER(iOS_9_0)) {
		%init(EddyCue);
	} else {
		%init(CraigFederighi);
	}

	%init;
}
