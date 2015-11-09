#import "HBTSBulletinProvider.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <BulletinBoard/BBLocalDataProviderStore.h>
#import "UIView+Helpers.h"

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

- (void)loadAllDataProvidersAndPerformMigration:(BOOL)arg1 {
	%orig;
	[self addDataProvider:[HBTSBulletinProvider sharedInstance] performMigration:YES];
}

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
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSClientSetStatusBarNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		HBTSStatusBarType type = (HBTSStatusBarType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue;
		NSString *sender = notification.userInfo[kHBTSMessageSenderKey];
		[[HBTSBulletinProvider sharedInstance] showBulletinOfType:type contactName:sender];
	}];
}
