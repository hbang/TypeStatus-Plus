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
	NSError *error = nil;
	[distributedCenter sendMessageAndReceiveReplyName:HBTSPlusServerSetStatusBarNotificationName userInfo:userInfo error:&error];

	if (error) {
		HBLogError(@"hideNotification—%@", error);
	}
}

+ (void)hideNotification {
	HBLogDebug(@"Posting hideNotification message on client side.");

	CPDistributedMessagingCenter *distributedCenter = [CPDistributedMessagingCenter centerNamed:HBTSPlusServerName];
	rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	NSError *error = nil;
	[distributedCenter sendMessageAndReceiveReplyName:HBTSPlusServerHideStatusBarNotificationName userInfo:nil error:&error];

	if (error) {
		HBLogError(@"showNotification—%@", error);
	}
}

@end
