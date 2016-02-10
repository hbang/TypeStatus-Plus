#import "HBTSPlusProvider.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../HBTSPlusPreferences.h"
#import "HBTSPlusProviderController.h"

@implementation HBTSPlusProvider

- (CPDistributedMessagingCenter *)_messagingCenter {
	static CPDistributedMessagingCenter *distributedCenter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		distributedCenter = [[CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName] retain];
		rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	});

	return distributedCenter;
}

#pragma mark - Messaging methods

- (void)showNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	NSDictionary *userInfo = @{
		kHBTSPlusMessageTitleKey: title ?: @"",
		kHBTSPlusMessageContentKey: content ?: @"",
		kHBTSPlusMessageIconNameKey: iconName ?: @"",
		kHBTSPlusAppIdentifierKey: self.appIdentifier
	};

	HBLogInfo(@"Posting showNotification message on client side.");

	[self._messagingCenter sendMessageName:kHBTSPlusServerSetStatusBarNotificationName userInfo:userInfo];
}

- (void)hideNotification {
	HBLogInfo(@"Posting hideNotification message on client side.");

	[self._messagingCenter sendMessageName:kHBTSPlusServerHideStatusBarNotificationName userInfo:nil];
}

@end
