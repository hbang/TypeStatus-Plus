#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../typestatus-private/HBTSStatusBarForegroundView.h"

%hook HBTSStatusBarForegroundView

- (void)_typeStatus_init {
	%orig;
	UITapGestureRecognizer *tapToOpenConvoRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(typeStatusPlus_openConversation:)];
	[self addGestureRecognizer:tapToOpenConvoRecognizer];
}

%new

- (void)typeStatusPlus_openConversation:(UIGestureRecognizer *)gestureRecognizer {
	HBLogDebug(@"Status bar tapped—sending notification");

	CPDistributedMessagingCenter *distributedCenter = [CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName];
	rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
	[distributedCenter sendMessageName:kHBTSPlusServerStatusBarTappedNotificationName userInfo:nil];
}

%end

%ctor {
	NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
	if ([bundleIdentifier isEqualToString:@"com.apple.accessibility.AccessibilityUIServer"] || [bundleIdentifier isEqualToString:@"com.apple.SafariViewService"]) {
	 	return;
	}

	%init;
}
