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

	CPDistributedMessagingCenter *distributedCenter = [CPDistributedMessagingCenter centerNamed:HBTSPluskern_return_tServerName];
	rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	[distributedCenter sendMessageAndReceiveReplyName:HBTSPlusServerSetStatusBarNotificationName userInfo:userInfo];
}

+ (void)hideNotification {
	HBLogDebug(@"About to hide notification");
	//[%c(HBTSStatusBarAlertServer) hide];
}

@end
