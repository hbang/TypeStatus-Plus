#import "HBTSPlusHelper.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBLockScreenManager.h>
#import "../HBTSPlusPreferences.h"

@implementation HBTSPlusHelper

+ (BOOL)shouldShowBanner {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	SBLockScreenManager *lockScreenManager = [%c(SBLockScreenManager) sharedInstance];
	BOOL onLockScreen = lockScreenManager.isUILocked;

	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	NSString *frontmostAppIdentifier = app._accessibilityFrontMostApplication.bundleIdentifier;

	BOOL shouldShowBanner = ([preferences showBannersOnLockScreen] && onLockScreen) || ([preferences showBannersOnHomeScreen] && !frontmostAppIdentifier && !onLockScreen) || ([preferences showBannersInApps] && frontmostAppIdentifier);
	return shouldShowBanner;
}

+ (BOOL)shouldVibrate {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	SBLockScreenManager *lockScreenManager = [%c(SBLockScreenManager) sharedInstance];
	BOOL onLockScreen = lockScreenManager.isUILocked;

	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	NSString *frontmostAppIdentifier = app._accessibilityFrontMostApplication.bundleIdentifier;

	BOOL shouldVibrate =  ([preferences vibrateOnLockScreen] && onLockScreen) || ([preferences vibrateOnHomeScreen] && !frontmostAppIdentifier && !onLockScreen) || ([preferences vibrateInApps] && frontmostAppIdentifier);

	return shouldVibrate;
}

@end
