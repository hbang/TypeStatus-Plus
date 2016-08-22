#import "HBTSPlusPreferences.h"
#import "../springboard/HBTSPlusServer.h"
#import "../springboard/HBTSPlusTapToOpenController.h"
#import "../typestatus-private/HBTSStatusBarForegroundView.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <libstatusbar/UIStatusBarCustomItem.h>
#import <libstatusbar/UIStatusBarCustomItemView.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import "HBTSStatusBarUnreadItemView.h"

CPDistributedMessagingCenter *distributedCenter;

@interface HBTSStatusBarForegroundView (TapToOpen)

@property (nonatomic, retain) UITapGestureRecognizer *tapToOpenConvoRecognizer;

@end

#pragma mark - Tap to open

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

#pragma mark - Unread count in status bar

%hook UIStatusBarCustomItem

- (Class)viewClass {
	if ([self.indicatorName isEqualToString:@"TypeStatusPlusUnreadCount"]) {
		return %c(HBTSStatusBarUnreadItemView);
	}

	return %orig;
}

%end

#pragma mark - TypeStatus hooks

%hook HBTSStatusBarAlertController

- (void)_receivedStatusNotification:(NSNotification *)notification {
	// if we're showing a banner, we probably should not show the regular ts notification
	// TODO: why can’t we just access
	NSDictionary *result = IN_SPRINGBOARD ? [[%c(HBTSPlusServer) sharedInstance] recievedShowBannersMessage:nil] : [distributedCenter sendMessageAndReceiveReplyName:kHBTSPlusServerShowBannersNotificationName userInfo:nil];
	BOOL shouldShowBanners = [result[kHBTSPlusShouldShowBannersKey] boolValue];
	if (shouldShowBanners) {
		return;
	}
	%orig;
}

%end

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusClient.dylib", RTLD_LAZY);

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
