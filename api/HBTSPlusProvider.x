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

- (void)showNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	HBLogWarn(@"%@: %@ is deprecated. Please transition to showNotification:.", self.class, NSStringFromSelector(_cmd));

	// make a notification from the args and post it
	HBTSNotification *notification = [[HBTSNotification alloc] init];
	notification.content = [NSString stringWithFormat:@"%@ %@", title, content];
	notification.boldRange = NSMakeRange(0, title.length);
	notification.statusBarIconName = iconName;
	[self showNotification:notification];
}

- (void)showNotificationWithIconName:(NSString *)iconName content:(NSString *)content boldRange:(NSRange)boldRange {
	HBLogWarn(@"%@: %@ is deprecated. Please transition to showNotification:.", self.class, NSStringFromSelector(_cmd));

	// make a notification from the args and post it
	HBTSNotification *notification = [[HBTSNotification alloc] init];
	notification.content = content;
	notification.boldRange = boldRange;
	notification.statusBarIconName = iconName;
	[self showNotification:notification];
}

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
