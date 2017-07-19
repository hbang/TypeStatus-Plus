#import "HBTSPlusStateHelper.h"
#import "HBTSPlusPreferences.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBLockScreenManager.h>

@implementation HBTSPlusStateHelper

+ (BOOL)_isAtLockScreen {
	return ((SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance]).isUILocked;
}

+ (BOOL)_isAtHomeScreen {
	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	return !self._isAtLockScreen && !app._accessibilityFrontMostApplication.bundleIdentifier;
}

+ (BOOL)shouldShowBanner {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	if (!preferences.enabled) {
		return NO;
	} else if (self._isAtLockScreen) {
		return preferences.showBannersOnLockScreen;
	} else if (self._isAtHomeScreen) {
		return preferences.showBannersOnHomeScreen;
	} else {
		return preferences.showBannersInApps;
	}
}

+ (BOOL)shouldVibrate {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	if (!preferences.enabled) {
		return NO;
	} else if (self._isAtLockScreen) {
		return preferences.vibrateOnLockScreen;
	} else if (self._isAtHomeScreen) {
		return preferences.vibrateOnHomeScreen;
	} else {
		return preferences.vibrateInApps;
	}
}

@end
