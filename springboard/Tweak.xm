#import "HBTSBulletinProvider.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <BulletinBoard/BBLocalDataProviderStore.h>
#import <version.h>
#import <AudioToolbox/AudioToolbox.h>

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

@interface HBTSStatusBarTitleItemView : UIView

@property (nonatomic, retain) NSString *text;

@end

@interface HBTSStatusBarForegroundView : UIView

@property (nonatomic, retain) UIView *containerView;

@property (nonatomic, retain) HBTSStatusBarTitleItemView *titleItemView;

@end

%hook HBTSStatusBarForegroundView

- (void)_typeStatus_init {
	%orig;
	UITapGestureRecognizer *tapToOpenConvoRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(typeStatusPlus_openConversation:)];
	[self.containerView addGestureRecognizer:tapToOpenConvoRecognizer];
}

%new

- (void)typeStatusPlus_openConversation:(UIGestureRecognizer *)gestureRecognizer {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://open?address=%@", self.titleItemView.text]]];
}

%end

#pragma mark - Notification Center

%hook BBLocalDataProviderStore

%group EddyCue
- (void)loadAllDataProvidersAndPerformMigration:(BOOL)performMigration {
	%orig;
	[self addDataProvider:[HBTSBulletinProvider sharedInstance] performMigration:performMigration];
}
%end

%group CraigFederighi
- (void)loadAllDataProviders {
	%orig;
	[self addDataProvider:[HBTSBulletinProvider sharedInstance]];
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

}

%end

#pragma mark - Constructor

%ctor {
	%init;

	if (IS_IOS_OR_NEWER(iOS_9_0)) {
		%init(EddyCue);
	} else {
		%init(CraigFederighi);
	}

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSClientSetStatusBarNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		HBTSStatusBarType type = (HBTSStatusBarType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue;
		NSString *sender = notification.userInfo[kHBTSMessageSenderKey];
		[[HBTSBulletinProvider sharedInstance] showBulletinOfType:type contactName:sender];

		AudioServicesPlaySystemSoundWithVibration(4095, nil, @{
			@"VibePattern": @[ @YES, @(50) ],
			@"Intensity": @1
		});
	}];
}
