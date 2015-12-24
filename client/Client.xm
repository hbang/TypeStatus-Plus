#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../typestatus-private/HBTSStatusBarForegroundView.h"
#import <libstatusbar/UIStatusBarCustomItem.h>
#import <libstatusbar/UIStatusBarCustomItemView.h>
#import "../springboard/HBTSPlusServer.h"
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import "../HBTSPlusPreferences.h"

CPDistributedMessagingCenter *distributedCenter;

%hook HBTSStatusBarForegroundView

- (void)_typeStatus_init {
	%orig;
	UITapGestureRecognizer *tapToOpenConvoRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(typeStatusPlus_openConversation:)];
	[self addGestureRecognizer:tapToOpenConvoRecognizer];
}

%new

- (void)typeStatusPlus_openConversation:(UIGestureRecognizer *)gestureRecognizer {
	HBLogDebug(@"Status bar tapped—sending notification");

	[distributedCenter sendMessageName:kHBTSPlusServerStatusBarTappedNotificationName userInfo:nil];
}

%end

%hook UIStatusBarCustomItemView

- (_UILegibilityImageSet *)contentsImage {
	if ([self.item.indicatorName isEqualToString:@"TypeStatusPlus"]) {
		NSInteger badgeCount = 0;
		if (IN_SPRINGBOARD) {
			SBApplication *messagesApplication = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier: [[%c(HBTSPlusPreferences) sharedInstance] applicationUsingUnreadCount]];
			badgeCount = [messagesApplication badgeNumberOrString].longValue;
		} else {
			NSDictionary *result = [distributedCenter sendMessageAndReceiveReplyName:kHBTSPlusServerGetUnreadCountNotificationName userInfo:nil];
			badgeCount = ((NSNumber *)result[kHBTSPlusBadgeCountKey]).integerValue;
		}

		if (badgeCount == 0) {
			return nil;
		}
		return [self imageWithText:[NSString stringWithFormat:@"%li", (long)badgeCount]];
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
