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

	if (![[%c(HBTSPlusPreferences) sharedInstance] enabled]) {
		return;
	}

	[distributedCenter sendMessageName:kHBTSPlusServerStatusBarTappedNotificationName userInfo:nil];
}

%end

%hook UIStatusBarCustomItemView

- (_UILegibilityImageSet *)contentsImage {
	if ([[%c(HBTSPlusPreferences) sharedInstance] enabled] && [self.item.indicatorName isEqualToString:@"TypeStatusPlus"]) {
		id badgeNumberOrString = nil;
		if (IN_SPRINGBOARD) {
			NSString *bundleIdentifier = [[%c(HBTSPlusPreferences) sharedInstance] applicationUsingUnreadCount];
			SBApplication *messagesApplication = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
			badgeNumberOrString = [messagesApplication badgeNumberOrString];
		} else {
			NSDictionary *result = [distributedCenter sendMessageAndReceiveReplyName:kHBTSPlusServerGetUnreadCountNotificationName userInfo:nil];
			badgeNumberOrString = result[kHBTSPlusBadgeCountKey];
		}
		NSString *badgeCount = [badgeNumberOrString isKindOfClass:NSNumber.class] ? [badgeNumberOrString stringValue] : badgeNumberOrString;

		return badgeCount ? [self imageWithText:badgeCount] : nil;
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
