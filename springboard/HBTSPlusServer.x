#import "HBTSPlusServer.h"
#import "HBTSPlusBulletinProvider.h"
#import "HBTSPlusPreferences.h"
#import "HBTSPlusStateHelper.h"
#import "HBTSPlusTapToOpenController.h"
#import "../api/HBTSPlusProviderController.h"
#import "../typestatus-private/HBTSStatusBarAlertServer.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import <TypeStatusPlusProvider/HBTSNotification.h>

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
		_distributedCenter = [CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName];
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
	HBTSNotification *notification = [[HBTSNotification alloc] initWithDictionary:userInfo];

	// give the tap to open controller context
	HBTSPlusTapToOpenController *tapToOpenController = [HBTSPlusTapToOpenController sharedInstance];
	tapToOpenController.appIdentifier = notification.sourceBundleID;
	tapToOpenController.actionURL = notification.actionURL;

	// get the enabled state of the provider
	HBTSPlusProvider *provider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:notification.sourceBundleID];
	BOOL enabled = [[HBTSPlusProviderController sharedInstance] providerIsEnabled:provider];

	// determine whether the app is in the foreground
	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	BOOL inForeground = [app._accessibilityFrontMostApplication.bundleIdentifier isEqualToString:notification.sourceBundleID];

	// if we’re disabled, or we’re in the foreground and the user doesn’t want
	// foreground notifications, return
	if (!enabled || (inForeground && ![[%c(HBTSPlusPreferences) sharedInstance] showWhenInForeground])) {
		return nil;
	}

	// send it to typestatus
	[%c(HBTSStatusBarAlertServer) sendAlertWithIconName:notification.statusBarIconName text:notification.content boldRange:notification.boldRange animatingInDirection:YES timeout:-1];

	// show as a banner if desired
	if ([HBTSPlusStateHelper shouldShowBanner]) {
		[[HBTSPlusBulletinProvider sharedInstance] showBulletinForNotification:notification];
	}

	return nil;
}

- (NSDictionary *)receivedHideStatusBarMessage:(NSString *)message {
	HBLogDebug(@"Received hide message on server side.");

	[%c(HBTSStatusBarAlertServer) hide];

	return nil;
}

- (NSDictionary *)receivedGetUnreadCountMessage:(NSString *)message {
	// get the bundle ids the user wants
	NSArray <NSString *> *apps = [[%c(HBTSPlusPreferences) sharedInstance] unreadCountApps];
	NSInteger badgeCount = 0;

	for (NSString *bundleIdentifier in apps) {
		// get the SBApplication
		SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];

		// get the badge count (hopefully an NSNumber) and add it to the count if
		// it’s not zero (hopefully not negative)
		NSNumber *badgeNumber = app.badgeNumberOrString;
		badgeCount += MAX(0, badgeNumber.integerValue);
	}

	// return the badge if we have one, or otherwise an empty string
	return @{ kHBTSPlusBadgeCountKey: badgeCount > 0 ? @(badgeCount) : @"" };
}

- (NSDictionary *)recievedShowBannersMessage:(NSString *)message {
	// grab the value and return it
	BOOL shouldShowBanner = [HBTSPlusStateHelper shouldShowBanner];
	return @{kHBTSPlusShouldShowBannersKey: @(shouldShowBanner)};
}

@end
