#import "HBTSPlusStateHelper.h"
#import "HBTSPlusPreferences.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBLockScreenManager.h>

@implementation HBTSPlusStateHelper

+ (BOOL)shouldShowBanner {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	SBLockScreenManager *lockScreenManager = [%c(SBLockScreenManager) sharedInstance];
	BOOL onLockScreen = lockScreenManager.isUILocked;

	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	NSString *frontmostAppIdentifier = app._accessibilityFrontMostApplication.bundleIdentifier;

	if (onLockScreen) {
		// lock screen
		return preferences.showBannersOnLockScreen;
	} else if (!frontmostAppIdentifier && !onLockScreen) {
		// home screen
		return preferences.showBannersOnHomeScreen;
	} else if (frontmostAppIdentifier) {
		// apps
		return preferences.showBannersInApps;
	} else {
		// ???
		return YES;
	}
}

+ (BOOL)shouldVibrate {
	// TODO: this is pretty much the same as above with just one thing changed?
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	SBLockScreenManager *lockScreenManager = [%c(SBLockScreenManager) sharedInstance];
	BOOL onLockScreen = lockScreenManager.isUILocked;

	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	NSString *frontmostAppIdentifier = app._accessibilityFrontMostApplication.bundleIdentifier;

	if (onLockScreen) {
		// lock screen
		return preferences.vibrateOnLockScreen;
	} else if (!frontmostAppIdentifier && !onLockScreen) {
		// home screen
		return preferences.vibrateOnHomeScreen;
	} else if (frontmostAppIdentifier) {
		// apps
		return preferences.vibrateInApps;
	} else {
		// ???
		return YES;
	}
}

@end
