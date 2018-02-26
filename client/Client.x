#import "HBTSPlusClient.h"
#import "HBTSPlusPreferences.h"
#import "HBTSStatusBarUnreadItemView.h"
#import "../typestatus-private/HBTSStatusBarForegroundView.h"
#import <libstatusbar/UIStatusBarCustomItem.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <TypeStatusProvider/TypeStatusProvider.h>
#import <UIKit/UIStatusBar.h>

@interface HBTSStatusBarForegroundView ()

@property (nonatomic, retain) UITapGestureRecognizer *tapToOpenConvoRecognizer;

@end

HBTSProviderController *controller;

#pragma mark - Backgrounding

%hook UIApplication

- (void)_deactivateForReason:(NSInteger)reason notify:(BOOL)notify {
	if ([controller doesApplicationIdentifierRequireBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		notify = NO;
	}

	%orig;
}

- (BOOL)_isLaunchedSuspended {
	return [controller doesApplicationIdentifierRequireBackgrounding:[NSBundle mainBundle].bundleIdentifier] ? NO : %orig;
}

- (BOOL)isSuspended {
	return [controller doesApplicationIdentifierRequireBackgrounding:[NSBundle mainBundle].bundleIdentifier] ? NO : %orig;
}

- (BOOL)isSuspendedUnderLock {
	return [controller doesApplicationIdentifierRequireBackgrounding:[NSBundle mainBundle].bundleIdentifier] ? NO : %orig;
}

- (BOOL)isSuspendedEventsOnly {
	return [controller doesApplicationIdentifierRequireBackgrounding:[NSBundle mainBundle].bundleIdentifier] ? NO : %orig;
}

%end

#pragma mark - Provider

%hook HBTSProvider

- (BOOL)isEnabled {
	HBTSPlusPreferences *preferences = [HBTSPlusPreferences sharedInstance];

	if (self.preferencesBundle) {
		// the provider manages its own preferences. return YES
		return YES;
	} else {
		// ask the preferences if we're enabled
		return [preferences isProviderEnabled:self.appIdentifier];
	}
}

%end

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
	// lsb seems like it's meant to provide a way to customise the class of an item, but it doesn't
	// seem to work, i guess? so we manually set the item view class by returning it here
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

#pragma mark - Constructor

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusClient.dylib", RTLD_LAZY);

	// ensure we don't do anything if typestatus hasn't loaded (intentionally or not)
	if (![UIStatusBar instancesRespondToSelector:@selector(_typeStatus_foregroundView)]) {
		return;
	}

	// get the client rolling
	[HBTSPlusClient sharedInstance];
	controller = [HBTSProviderController sharedInstance];

	%init;

	// if lsb is installed, init the hooks for it
	if (%c(UIStatusBarCustomItem)) {
		%init(HasLibstatusbar);
	}
}
