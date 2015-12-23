#import "HBTSPlusProvider.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <Cephei/HBPreferences.h>

@implementation HBTSPlusProvider {
	HBPreferences *_preferences;
}

+ (CPDistributedMessagingCenter *)_messagingCenter {
	CPDistributedMessagingCenter *distributedCenter = [CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName];
	rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	return distributedCenter;
}

#pragma mark - Initialization

- (instancetype)init {
	if (self = [super init]) {
		_preferences = [[HBPreferences alloc] initWithIdentifier:@"ws.hbang.typestatusplus"];
	}
	return self;
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
	NSNumber *enabled = [_preferences objectForKey:identifier];
	return enabled ? enabled.boolValue : YES;
}

- (BOOL)providerIsEnabled:(HBTSPlusProvider *)provider {
	if (provider.preferencesBundle && provider.preferencesClass) {
		return YES;
	} else {
		return [self providerIdentifierIsEnabled:provider.appIdentifier];
	}
}

@end
