#import "HBTSBulletinProvider.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <BulletinBoard/BBLocalDataProviderStore.h>
#import "UIView+Helpers.h"
#import <version.h>

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
	}];
}
