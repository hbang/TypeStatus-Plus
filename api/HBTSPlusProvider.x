#import "HBTSPlusProvider.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../HBTSPlusPreferences.h"
#import "HBTSPlusProviderController.h"

@implementation HBTSPlusProvider

- (CPDistributedMessagingCenter *)_messagingCenter {
	CPDistributedMessagingCenter *distributedCenter = [CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName];
	rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	return distributedCenter;
}

#pragma mark - Messaging methods

- (void)showNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	BOOL enabled = [[HBTSPlusProviderController sharedInstance] providerIsEnabled:self];
	if (!enabled) {
		return;
	}

	NSDictionary *userInfo = @{
		kHBTSPlusMessageTitleKey: title ?: @"",
		kHBTSPlusMessageContentKey: content ?: @"",
		kHBTSPlusMessageIconNameKey: iconName ?: @""
	};

	HBLogDebug(@"Posting showNotification message on client side.");

	[self._messagingCenter sendMessageName:kHBTSPlusServerSetStatusBarNotificationName userInfo:userInfo];
}

- (void)hideNotification {
	BOOL enabled = [[HBTSPlusProviderController sharedInstance] providerIsEnabled:self];
	if (!enabled) {
		return;
	}

	HBLogDebug(@"Posting hideNotification message on client side.");

	[self._messagingCenter sendMessageName:kHBTSPlusServerHideStatusBarNotificationName userInfo:nil];
}

@end
