#import "HBTSPlusProvider.h"
#import "HBTSPlusPreferences.h"
#import "HBTSPlusProviderController.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

@implementation HBTSPlusProvider

- (CPDistributedMessagingCenter *)_messagingCenter {
	static CPDistributedMessagingCenter *distributedCenter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		distributedCenter = [CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName];
		rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	});

	return distributedCenter;
}

#pragma mark - State

- (BOOL)isEnabled {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	if (!preferences.enabled) {
		// the tweak is globally disabled, so this provider is therefore disabled
		return NO;
	} else if (self.preferencesBundle) {
		// the provider manages its own preferences. return YES
		return YES;
	} else {
		// ask the preferences if we're enabled
		return [preferences providerIsEnabled:self.appIdentifier];
	}
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
