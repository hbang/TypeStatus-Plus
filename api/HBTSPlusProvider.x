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

	HBLogDebug(@"Posting message on client side.");

	CPDistributedMessagingCenter *distributedCenter = [CPDistributedMessagingCenter centerNamed:HBTSPlusServerName];
	rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	NSError *error = nil;
	[distributedCenter sendMessageAndReceiveReplyName:HBTSPlusServerSetStatusBarNotificationName userInfo:userInfo error:&error];

	if (error) {
		HBLogError(@"%@", error);
	}
}

+ (void)hideNotification {
	HBLogDebug(@"About to hide notification");
	//[%c(HBTSStatusBarAlertServer) hide];
}

@end
