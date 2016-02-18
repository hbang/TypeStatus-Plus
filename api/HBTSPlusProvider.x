#import "HBTSPlusProvider.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../HBTSPlusPreferences.h"
#import "HBTSPlusProviderController.h"

@implementation HBTSPlusProvider

- (CPDistributedMessagingCenter *)_messagingCenter {
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
	NSParameterAssert(title);

	NSString *text = nil;

	if (content) {
		text = [NSString stringWithFormat:@"%@ %@", title, content];
	} else {
		text = title;
	}

	[self showNotificationWithIconName:iconName content:text boldRange:NSMakeRange(0, title.length)];
}

- (void)showNotificationWithIconName:(NSString *)iconName content:(NSString *)content boldRange:(NSRange)boldRange {
	NSDictionary *userInfo = @{
		kHBTSPlusMessageIconNameKey: iconName ?: @"",
		kHBTSPlusMessageContentKey: content ?: @"",
		kHBTSPlusMessageBoldRangeKey: @[ @(boldRange.location), @(boldRange.length) ],
		kHBTSPlusAppIdentifierKey: self.appIdentifier
	};

	HBLogInfo(@"Posting showNotification message on client side.");

	[self._messagingCenter sendMessageName:kHBTSPlusServerSetStatusBarNotificationName userInfo:userInfo];
}

- (void)hideNotification {
	HBLogInfo(@"Posting hideNotification message on client side.");

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
