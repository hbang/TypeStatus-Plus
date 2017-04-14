#import "HBTSPlusServer.h"
#import "HBTSPlusAlertController.h"
#import "HBTSPlusPreferences.h"
#import "HBTSPlusStateHelper.h"
#import "HBTSPlusTapToOpenController.h"
#import "../api/HBTSNotification.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import <rocketbootstrap/rocketbootstrap.h>

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
		[_distributedCenter registerForMessageName:kHBTSPlusServerShowBannersNotificationName target:self selector:@selector(recievedShowBannersMessage:)];
	}
	return self;
}

- (NSDictionary *)receivedSetStatusBarMessage:(NSString *)message withUserInfo:(NSDictionary *)userInfo {
	HBLogDebug(@"Received set message on server side.");

	// deserialize to an HBTSNotification
	HBTSNotification *notification = [[HBTSNotification alloc] initWithDictionary:userInfo];

	// hand over to the alert controller
	[HBTSPlusAlertController sendNotification:notification];

	return nil;
}

- (NSDictionary *)receivedHideStatusBarMessage:(NSString *)message {
	HBLogDebug(@"Received hide message on server side.");

	// invoke a hide command
	[HBTSPlusAlertController hide];

	return nil;
}

- (NSDictionary *)recievedShowBannersMessage:(NSString *)message {
	// grab the value and return it
	BOOL shouldShowBanner = [HBTSPlusStateHelper shouldShowBanner];
	return @{kHBTSPlusShouldShowBannersKey: @(shouldShowBanner)};
}

@end
