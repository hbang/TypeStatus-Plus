#import "HBTSPlusProvider.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@implementation HBTSPlusProvider

+ (void)showNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	NSDictionary *userInfo = @{
		kHBTSPlusMessageTitleKey: title ?: @"",
		kHBTSPlusMessageContentKey: content ?: @"",
		kHBTSPlusMessageIconNameKey: iconName ?: @""
	};

	HBLogDebug(@"Posting showNotification message on client side.");

	CPDistributedMessagingCenter *distributedCenter = [CPDistributedMessagingCenter centerNamed:HBTSPlusServerName];
	rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	[distributedCenter sendMessageName:HBTSPlusServerSetStatusBarNotificationName userInfo:userInfo];
}

+ (void)hideNotification {
	HBLogDebug(@"Posting hideNotification message on client side.");

	CPDistributedMessagingCenter *distributedCenter = [CPDistributedMessagingCenter centerNamed:HBTSPlusServerName];
	rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	[distributedCenter sendMessageName:HBTSPlusServerHideStatusBarNotificationName userInfo:nil];
}

@end
