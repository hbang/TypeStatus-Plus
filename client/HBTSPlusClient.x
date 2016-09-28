#import "HBTSPlusClient.h"
#import "../springboard/HBTSPlusServer.h"
#import "../springboard/HBTSPlusTapToOpenController.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

@implementation HBTSPlusClient {
	CPDistributedMessagingCenter *_distributedCenter;
}

+ (instancetype)sharedInstance {
	static HBTSPlusClient *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		if (!IN_SPRINGBOARD) {
			_distributedCenter = [CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName];
			rocketbootstrap_distributedmessagingcenter_apply(_distributedCenter);
		}
	}

	return self;
}

- (NSInteger)badgeCount {
	NSDictionary *result;

	if (IN_SPRINGBOARD) {
		result = [[%c(HBTSPlusServer) sharedInstance] receivedGetUnreadCountMessage:nil];
	} else {
		result = [_distributedCenter sendMessageAndReceiveReplyName:kHBTSPlusServerGetUnreadCountNotificationName userInfo:nil];
	}

	NSNumber *badgeCount = result[kHBTSPlusBadgeCountKey];
	return badgeCount ? badgeCount.integerValue : 0;
}

- (BOOL)showBanners {
	NSDictionary *result;

	if (IN_SPRINGBOARD) {
		result = [[%c(HBTSPlusServer) sharedInstance] recievedShowBannersMessage:nil];
	} else {
		result = [_distributedCenter sendMessageAndReceiveReplyName:kHBTSPlusServerShowBannersNotificationName userInfo:nil];
	}

	NSNumber *value = result[kHBTSPlusShouldShowBannersKey];
	return value ? value.boolValue : NO;
}

- (void)statusBarTapped {
	if (IN_SPRINGBOARD) {
		[[%c(HBTSPlusTapToOpenController) sharedInstance] receivedStatusBarTappedMessage:nil];
	} else {
		[_distributedCenter sendMessageName:kHBTSPlusServerStatusBarTappedNotificationName userInfo:nil];
	}
}

@end
