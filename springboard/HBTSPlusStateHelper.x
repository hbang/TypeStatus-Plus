#import "HBTSPlusStateHelper.h"
#import "HBTSPlusBulletinProvider.h"
#import "HBTSPlusPreferences.h"
#import <SpringBoard/SBLockScreenManager.h>

@implementation HBTSPlusStateHelper

+ (BOOL)_isAtLockScreen {
	return ((SBLockScreenManager *)[%c(SBLockScreenManager) sharedInstance]).isUILocked;
}

+ (BOOL)shouldShowBanner {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	if (!preferences.enabled) {
		return NO;
	}
	
	HBTSPlusBulletinProvider *provider = [HBTSPlusBulletinProvider sharedInstance];
	return self._isAtLockScreen ? provider.showsInLockScreen : provider.showsWhenUnlocked;
}

+ (BOOL)shouldVibrate {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	if (!preferences.enabled) {
		return NO;
	}
	
	return self._isAtLockScreen ? preferences.vibrateOnLockScreen : preferences.vibrateInApps;
}

@end
