#import "HBTSPlusProvider.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../HBTSPlusPreferences.h"

@implementation HBTSPlusProvider

+ (CPDistributedMessagingCenter *)_messagingCenter {
	CPDistributedMessagingCenter *distributedCenter = [CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName];
	rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	return distributedCenter;
}

#pragma mark - Messaging methods

+ (void)showNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	NSDictionary *userInfo = @{
		kHBTSPlusMessageTitleKey: title ?: @"",
		kHBTSPlusMessageContentKey: content ?: @"",
		kHBTSPlusMessageIconNameKey: iconName ?: @""
	};

	HBLogDebug(@"Posting showNotification message on client side.");

	[self._messagingCenter sendMessageName:kHBTSPlusServerSetStatusBarNotificationName userInfo:userInfo];
}

+ (void)hideNotification {
	HBLogDebug(@"Posting hideNotification message on client side.");

	[self._messagingCenter sendMessageName:kHBTSPlusServerHideStatusBarNotificationName userInfo:nil];
}

#pragma mark - Preferences

- (BOOL)providerIdentifierIsEnabled:(NSString *)identifier {
	NSNumber *enabled = [%c(HBTSPlusPreferences) sharedInstance][identifier];
	return enabled ? enabled.boolValue : YES;
}

- (BOOL)providerIsEnabled:(HBTSPlusProvider *)provider {
	if (![[%c(HBTSPlusPreferences) sharedInstance] enabled]) {
		return NO;
	}
	if (provider.preferencesBundle && provider.preferencesClass) {
		return YES;
	} else {
		return [self providerIdentifierIsEnabled:provider.appIdentifier];
	}
}

@end
