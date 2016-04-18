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
		distributedCenter = [[CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName] retain];
		rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	});

	return distributedCenter;
}

#pragma mark - Messaging methods

- (void)showNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	// make a notification from the args and post it
	HBTSNotification *notification = [[[HBTSNotification alloc] init] autorelease];
	notification.title = title;
	notification.subtitle = content;
	notification.statusBarIconName = iconName;
	[self showNotification:notification];
}

- (void)showNotificationWithIconName:(NSString *)iconName content:(NSString *)content boldRange:(NSRange)boldRange {
	// make a notification from the args and post it
	HBTSNotification *notification = [[[HBTSNotification alloc] init] autorelease];
	notification.content = content;
	notification.boldRange = boldRange;
	notification.statusBarIconName = iconName;
	[self showNotification:notification];
}

- (void)showNotification:(HBTSNotification *)notification {
	// no-op if we’re not enabled
	if (![[HBTSPlusProviderController sharedInstance] providerIsEnabled:self]) {
		return;
	}

	// override the section id with the app id if it’s nil
	if (!notification.sectionID) {
		notification.sectionID = _appIdentifier;
	}

	HBLogDebug(@"Posting showNotification message on client side.");

	// post the notification
	[self._messagingCenter sendMessageName:kHBTSPlusServerSetStatusBarNotificationName userInfo:notification.dictionaryRepresentation];
}

- (void)hideNotification {
	// no-op if we’re not enabled
	if (![[HBTSPlusProviderController sharedInstance] providerIsEnabled:self]) {
		return;
	}

	HBLogDebug(@"Posting hideNotification message on client side.");

	// post the notification
	[self._messagingCenter sendMessageName:kHBTSPlusServerHideStatusBarNotificationName userInfo:nil];
}

#pragma mark - Memory management

- (void)dealloc {
	[_name release];
	[_appIdentifier release];
	[_preferencesBundle release];
	[_preferencesClass release];

	[super dealloc];
}

@end
