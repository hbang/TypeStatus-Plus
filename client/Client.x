#import "HBTSPlusClient.h"
#import "HBTSPlusPreferences.h"
#import "HBTSStatusBarUnreadItemView.h"
#import "../typestatus-private/HBTSStatusBarForegroundView.h"
#import <libstatusbar/UIStatusBarCustomItem.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>

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

%new - (void)typeStatusPlus_openConversation:(UIGestureRecognizer *)gestureRecognizer {
	HBLogDebug(@"Status bar tapped—sending notification");

	if (![HBTSPlusPreferences sharedInstance].enabled) {
		return;
	}

	[[HBTSPlusClient sharedInstance] statusBarTapped];
}

%end

#pragma mark - Unread count in status bar

%group HasLibstatusbar
%hook UIStatusBarCustomItem

- (Class)viewClass {
	if ([self.indicatorName isEqualToString:@"TypeStatusPlusUnreadCount"]) {
		return %c(HBTSStatusBarUnreadItemView);
	}

	return %orig;
}

%end
%end

#pragma mark - TypeStatus hooks

%hook HBTSStatusBarAlertController

- (void)_receivedStatusNotification:(NSNotification *)notification {
	// if we're showing a banner, we probably should not show the regular ts notification
	if (![HBTSPlusClient sharedInstance].showBanners) {
		%orig;
	}
}

%end

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusClient.dylib", RTLD_LAZY);

	NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;

	if ([bundleIdentifier isEqualToString:@"com.apple.accessibility.AccessibilityUIServer"] || [bundleIdentifier isEqualToString:@"com.apple.SafariViewService"]) {
		return;
	}

	%init;

	if (%c(UIStatusBarCustomItem)) {
		%init(HasLibstatusbar);
	}
}
