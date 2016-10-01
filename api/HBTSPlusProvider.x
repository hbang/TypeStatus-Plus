#import "HBTSPlusProvider.h"
#import "HBTSPlusPreferences.h"
#import "HBTSPlusProviderController.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

@implementation HBTSPlusProvider

- (CPDistributedMessagingCenter *)_messagingCenter {
	// only do this once so we don’t have to retrieve it every time
	static CPDistributedMessagingCenter *distributedCenter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		distributedCenter = [CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName];
		rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	});

	return distributedCenter;
}

#pragma mark - Messaging methods

- (void)showNotification:(HBTSNotification *)notification {
	// override the section id with the app id if it’s nil
	if (!notification.sourceBundleID) {
		notification.sourceBundleID = _appIdentifier;
	}

	HBLogDebug(@"Posting showNotification message on client side.");

	// post the notification
	[self._messagingCenter sendMessageName:kHBTSPlusServerSetStatusBarNotificationName userInfo:notification.dictionaryRepresentation];
}

- (void)hideNotification {
	HBLogDebug(@"Posting hideNotification message on client side.");

	// post the notification
	[self._messagingCenter sendMessageName:kHBTSPlusServerHideStatusBarNotificationName userInfo:nil];
}

@end
