#import "HBTSPlusServer.h"
#import "rocketbootstrap/rocketbootstrap.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../typestatus-private/HBTSStatusBarAlertServer.h"
#import "HBTSPlusTapToOpenController.h"
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import "../HBTSPlusPreferences.h"

@implementation HBTSPlusServer

+ (instancetype)sharedInstance {
	static HBTSPlusServer *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		self._distributedCenter = [[CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName] retain];
		rocketbootstrap_distributedmessagingcenter_apply(self._distributedCenter);
		[self._distributedCenter runServerOnCurrentThread];

		[self._distributedCenter registerForMessageName:kHBTSPlusServerSetStatusBarNotificationName target:self selector:@selector(receivedSetStatusBarMessage:withUserInfo:)];
		[self._distributedCenter registerForMessageName:kHBTSPlusServerHideStatusBarNotificationName target:self selector:@selector(receivedHideStatusBarMessage:)];
		[self._distributedCenter registerForMessageName:kHBTSPlusServerStatusBarTappedNotificationName target:[HBTSPlusTapToOpenController sharedInstance] selector:@selector(receivedStatusBarTappedMessage:)];
		[self._distributedCenter registerForMessageName:kHBTSPlusServerGetUnreadCountNotificationName target:self selector:@selector(receivedGetUnreadCountMessage:)];
	}
	return self;
}

- (NSDictionary *)receivedSetStatusBarMessage:(NSString *)message withUserInfo:(NSDictionary *)userInfo {
	HBLogDebug(@"Recieved set message on server side.");

	NSString *title = userInfo[kHBTSPlusMessageTitleKey];
	NSString *content = userInfo[kHBTSPlusMessageContentKey];
	NSString *iconName = userInfo[kHBTSPlusMessageIconNameKey];

	[%c(HBTSStatusBarAlertServer) sendAlertWithIconName:iconName title:title content:content];

	return nil;
}

- (NSDictionary *)receivedHideStatusBarMessage:(NSString *)message {
	HBLogDebug(@"Recieved hide message on server side.");

	[%c(HBTSStatusBarAlertServer) hide];

	return nil;
}

- (NSDictionary *)receivedGetUnreadCountMessage:(NSString *)message {
	NSString *appIdentifier = [[%c(HBTSPlusPreferences) sharedInstance] applicationUsingUnreadCount];
	SBApplication *messagesApplication = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:appIdentifier];
	return @{kHBTSPlusBadgeCountKey: [messagesApplication badgeNumberOrString] ?: @""};
}

@end
