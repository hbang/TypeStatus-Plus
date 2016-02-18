#import "HBTSPlusServer.h"
#import "rocketbootstrap/rocketbootstrap.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../typestatus-private/HBTSStatusBarAlertServer.h"
#import "HBTSPlusTapToOpenController.h"
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import "../HBTSPlusPreferences.h"
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>
#import <SpringBoard/SpringBoard.h>
#import "HBTSPlusHelper.h"

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
		_distributedCenter = [[CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName] retain];
		rocketbootstrap_distributedmessagingcenter_apply(_distributedCenter);
		[_distributedCenter runServerOnCurrentThread];

		[_distributedCenter registerForMessageName:kHBTSPlusServerSetStatusBarNotificationName target:self selector:@selector(receivedSetStatusBarMessage:withUserInfo:)];
		[_distributedCenter registerForMessageName:kHBTSPlusServerHideStatusBarNotificationName target:self selector:@selector(receivedHideStatusBarMessage:)];
		[_distributedCenter registerForMessageName:kHBTSPlusServerStatusBarTappedNotificationName target:[HBTSPlusTapToOpenController sharedInstance] selector:@selector(receivedStatusBarTappedMessage:)];
		[_distributedCenter registerForMessageName:kHBTSPlusServerGetUnreadCountNotificationName target:self selector:@selector(receivedGetUnreadCountMessage:)];
		[_distributedCenter registerForMessageName:kHBTSPlusServerShowBannersNotificationName target:self selector:@selector(recievedShowBannersMessage:)];

	}
	return self;
}

- (NSDictionary *)receivedSetStatusBarMessage:(NSString *)message withUserInfo:(NSDictionary *)userInfo {
	HBLogInfo(@"Recieved set message on server side.");

	NSString *title = userInfo[kHBTSPlusMessageTitleKey];
	NSString *content = userInfo[kHBTSPlusMessageContentKey];
	NSString *iconName = userInfo[kHBTSPlusMessageIconNameKey];
	NSString *appIdentifier = userInfo[kHBTSPlusAppIdentifierKey];

	// tap to open controller needs this info
	[HBTSPlusTapToOpenController sharedInstance].appIdentifier = appIdentifier;

	HBTSPlusProvider *provider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:appIdentifier];
	BOOL enabled = [[HBTSPlusProviderController sharedInstance] providerIsEnabled:provider];

	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	BOOL inForeground = [app._accessibilityFrontMostApplication.bundleIdentifier isEqualToString:appIdentifier];

	if (!enabled || (![[%c(HBTSPlusPreferences) sharedInstance] showWhenInForeground] && inForeground)) {
		return nil;
	}

	[%c(HBTSStatusBarAlertServer) sendAlertWithIconName:iconName title:title content:content];

	return nil;
}

- (NSDictionary *)receivedHideStatusBarMessage:(NSString *)message {
	HBLogInfo(@"Recieved hide message on server side.");

	[%c(HBTSStatusBarAlertServer) hide];

	return nil;
}

- (NSDictionary *)receivedGetUnreadCountMessage:(NSString *)message {
	NSString *appIdentifier = [[%c(HBTSPlusPreferences) sharedInstance] applicationUsingUnreadCount];
	SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:appIdentifier];
	return @{kHBTSPlusBadgeCountKey: [app badgeNumberOrString] ?: @""};
}

- (NSDictionary *)recievedShowBannersMessage:(NSString *)message {
	BOOL shouldShowBanner = [HBTSPlusHelper shouldShowBanner];
	return @{kHBTSPlusShouldShowBannersKey: @(shouldShowBanner)};
}

@end
