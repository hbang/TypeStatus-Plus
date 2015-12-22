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

LSStatusBarItem *typingStatusBarItem;

extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);

#pragma mark - Notification Center

%hook BBLocalDataProviderStore

%group EddyCue
- (void)loadAllDataProvidersAndPerformMigration:(BOOL)performMigration {
	%orig;
	[self addDataProvider:[HBTSPlusBulletinProvider sharedInstance] performMigration:performMigration];
}
%end

%group CraigFederighi
- (void)loadAllDataProviders {
	%orig;
	[self addDataProvider:[HBTSPlusBulletinProvider sharedInstance]];
}
%end

%end

#pragma mark - Messages Count

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
	%orig;

	// is libstatusbar loaded? if not, let's try dlopening it
	if (!%c(LSStatusBarItem)) {
		dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	}

	// still not loaded? probably not installed. just bail out
	if (!%c(LSStatusBarItem)) {
		return;
	}

	typingStatusBarItem = [[[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatusplus.messageicon" alignment:StatusBarAlignmentRight] retain];
	typingStatusBarItem.imageName = @"TypeStatusPlus";
	typingStatusBarItem.visible = YES;
}

%end

%hook SBApplication

- (void)setBadge:(id)arg1 {
	if ([self.bundleIdentifier isEqualToString:@"com.apple.MobileSMS"]) {
		[typingStatusBarItem update];
	}
	%orig;
}

%end

#pragma mark - Constructor

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);

	[HBTSPlusServer sharedInstance];
	[HBTSPlusTapToOpenController sharedInstance];

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSClientSetStatusBarNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

		NSString *titleKey = notification.userInfo[kHBTSPlusMessageTitleKey];
		NSString *content = notification.userInfo[kHBTSPlusMessageContentKey];
		[[HBTSPlusBulletinProvider sharedInstance] showBulletinWithTitle:titleKey content:content];

		AudioServicesPlaySystemSoundWithVibration(4095, nil, @{
			@"VibePattern": @[ @YES, @(50) ],
			@"Intensity": @1
		});
	}];

	if (IS_IOS_OR_NEWER(iOS_9_0)) {
		%init(EddyCue);
	} else {
		%init(CraigFederighi);
	}

	%init;
}
