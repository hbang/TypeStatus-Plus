#import "HBTSPlusServer.h"
#import "HBTSPlusStateHelper.h"
#import "HBTSPlusTapToOpenController.h"
#import "../HBTSPlusPreferences.h"
#import "../typestatus-private/HBTSStatusBarAlertServer.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

@implementation HBTSPlusServer {
	CPDistributedMessagingCenter *_distributedCenter;
}

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
	HBLogDebug(@"Recieved set message on server side.");

	// deserialize to an HBTSNotification
	HBTSNotification *notification = [[[HBTSNotification alloc] initWithDictionary:userInfo] autorelease];

	// give the tap to open controller context
	HBTSPlusTapToOpenController *tapToOpenController = [HBTSPlusTapToOpenController sharedInstance];
	tapToOpenController.appIdentifier = [notification.sectionID copy];
	tapToOpenController.actionURL = [notification.actionURL copy];

	// get the enabled state of the provider
	HBTSPlusProvider *provider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:notification.sectionID];
	BOOL enabled = [[HBTSPlusProviderController sharedInstance] providerIsEnabled:provider];

	// determine whether the app is in the foreground
	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	BOOL inForeground = [app._accessibilityFrontMostApplication.bundleIdentifier isEqualToString:notification.sectionID];

	// if we’re disabled, or we’re in the foreground and the user doesn’t want
	// foreground notifications, return
	if (!enabled || (inForeground && ![[%c(HBTSPlusPreferences) sharedInstance] showWhenInForeground])) {
		return nil;
	}

	// send it to typestatus
	[%c(HBTSStatusBarAlertServer) sendAlertWithIconName:iconName text:content boldRange:boldRange animatingInDirection:YES timeout:-1];

	return nil;
}

- (NSDictionary *)receivedHideStatusBarMessage:(NSString *)message {
	HBLogDebug(@"Received hide message on server side.");

	[%c(HBTSStatusBarAlertServer) hide];

	return nil;
}

- (NSDictionary *)receivedGetUnreadCountMessage:(NSString *)message {
	// get the bundle id the user wants
	NSString *appIdentifier = [[%c(HBTSPlusPreferences) sharedInstance] applicationUsingUnreadCount];

	// and get the SBApplication of it
	SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:appIdentifier];

	// return the badge if we have one, or otherwise an empty string
	return @{kHBTSPlusBadgeCountKey: [app badgeNumberOrString] ?: @""};
}

- (NSDictionary *)recievedShowBannersMessage:(NSString *)message {
	// grab the value and return it
	BOOL shouldShowBanner = [HBTSPlusStateHelper shouldShowBanner];
	return @{kHBTSPlusShouldShowBannersKey: @(shouldShowBanner)};
}

@end
