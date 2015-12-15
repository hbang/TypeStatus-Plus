#import "HBTSPlusBulletinProvider.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <BulletinBoard/BBLocalDataProviderStore.h>
#import <version.h>
#import <AudioToolbox/AudioToolbox.h>
#import "HBTSPlusServer.h"
#import "HBTSPlusTapToOpenController.h"
#import <libstatusbar/LSStatusBarItem.h>

extern "C" void AudioServicesPlaySystemSoundWithVibration(SystemSoundID inSystemSoundID, id unknown, NSDictionary *options);

@interface SBIconViewMap : NSObject

+ (instancetype)homescreenMap;

@end

@interface SBIconModel : NSObject

@property (retain, nonatomic) NSDictionary *leafIconsByIdentifier;

@end

@interface SBIcon : NSObject

- (long long)badgeValue;

@end

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

	SBIconViewMap *map = [%c(SBIconViewMap) homescreenMap];
	SBIconModel *iconModel = MSHookIvar<SBIconModel *>(map, "_model");
	SBIcon *icon = iconModel.leafIconsByIdentifier[@"com.apple.MobileSMS"];
	long badgeCount = [icon badgeValue];
	HBLogDebug(@"The badge count is: %li", badgeCount);

	// is libstatusbar loaded? if not, let's try dlopening it
		if (!%c(LSStatusBarItem)) {
			dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
		}

		// still not loaded? probably not installed. just bail out
		if (!%c(LSStatusBarItem)) {
			HBLogWarn(@"attempting to display a status bar icon, but libstatusbar isn’t installed");
			return;
		}


			LSStatusBarItem *typingStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatusplus.messageicon" alignment:StatusBarAlignmentRight];
			typingStatusBarItem.customViewClass = @"HBTSPlusStatusBarUnreadCountView";
			typingStatusBarItem.visible = YES;


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
