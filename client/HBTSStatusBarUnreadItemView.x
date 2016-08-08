#import "HBTSStatusBarUnreadItemView.h"
#import <UIKit/_UILegibilityImageSet.h>
#import "../springboard/HBTSPlusServer.h"
#import "HBTSPlusPreferences.h"
#import <UIKit/UIStatusBarItem.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

%subclass HBTSStatusBarUnreadItemView : UIStatusBarCustomItemView

CPDistributedMessagingCenter *distributedCenter;

- (_UILegibilityImageSet *)contentsImage {
	if ([[%c(HBTSPlusPreferences) sharedInstance] enabled] && [self.item.indicatorName isEqualToString:@"TypeStatusPlusUnreadCount"]) {
		// if it's in springboard, then call through, if not, message through
		NSDictionary *result = IN_SPRINGBOARD ? [[%c(HBTSPlusServer) sharedInstance] receivedGetUnreadCountMessage:nil] : [distributedCenter sendMessageAndReceiveReplyName:kHBTSPlusServerGetUnreadCountNotificationName userInfo:nil];
		id badgeNumberOrString = result[kHBTSPlusBadgeCountKey];

		// this works because if it's a number it is converted to a string, if it's a string, it's converted to a string.
		return [self imageWithText:[NSString stringWithFormat:@"%@", badgeNumberOrString]];
	}
	return %orig;
}

%end

%ctor {
	if (!IN_SPRINGBOARD) {
		distributedCenter = [[CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName] retain];
		rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	}

	%init;
}