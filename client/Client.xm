#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../typestatus-private/HBTSStatusBarForegroundView.h"
#import <libstatusbar/UIStatusBarCustomItem.h>
#import <libstatusbar/UIStatusBarCustomItemView.h>
#import "../springboard/HBTSPlusServer.h"
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import "../HBTSPlusPreferences.h"
#import "../springboard/HBTSPlusTapToOpenController.h"

CPDistributedMessagingCenter *distributedCenter;

@interface HBTSStatusBarForegroundView (TapToOpen)

@property (nonatomic, retain) UITapGestureRecognizer *tapToOpenConvoRecognizer;

@end

%hook HBTSStatusBarForegroundView

%property (nonatomic, retain) UITapGestureRecognizer *tapToOpenConvoRecognizer;

- (void)_typeStatus_init {
	%orig;
	self.tapToOpenConvoRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(typeStatusPlus_openConversation:)];
	[self addGestureRecognizer:self.tapToOpenConvoRecognizer];
}

- (void)dealloc {
	[self.tapToOpenConvoRecognizer release];

	%orig;
}

%new

- (void)typeStatusPlus_openConversation:(UIGestureRecognizer *)gestureRecognizer {
	HBLogInfo(@"Status bar tapped—sending notification");

	if (![[%c(HBTSPlusPreferences) sharedInstance] enabled]) {
		return;
	}

	if (IN_SPRINGBOARD) {
		[[%c(HBTSPlusTapToOpenController) sharedInstance] receivedStatusBarTappedMessage:nil];
	} else {
		[distributedCenter sendMessageName:kHBTSPlusServerStatusBarTappedNotificationName userInfo:nil];
	}
}

%end

%hook UIStatusBarCustomItemView

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
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);

	NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
	if ([bundleIdentifier isEqualToString:@"com.apple.accessibility.AccessibilityUIServer"] || [bundleIdentifier isEqualToString:@"com.apple.SafariViewService"]) {
	 	return;
	}

	if (!IN_SPRINGBOARD) {
		distributedCenter = [[CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName] retain];
		rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	}

	%init;
}
