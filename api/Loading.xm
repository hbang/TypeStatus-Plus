#import "HBTSPlusProviderBackgroundingManager.h"
#import "HBTSPlusProviderController.h"
#import <AssertionServices/BKSProcessAssertion.h>
#import <AssertionServices/BKSProcessAssertionClient.h>
#import <BaseBoard/BSMutableSettings.h>
#import <SpringBoard/SBApplication.h>

%group SpringBoard
%hook SBAppSwitcherModel

- (void)_appActivationStateDidChange:(NSNotification *)notification {
	%orig;

	SBApplication *app = notification.object;

	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:app.bundleIdentifier]) {
		BSMutableSettings *settings = [[app valueForKey:@"_stateSettings"] valueForKey:@"_settings"];

		if ((settings.allSettings.count > 1 && [settings boolForSetting:BSSettingTypeThisIsAReminderToFillOutTheseEnumNames]) || [app valueForKey:@"_activationSettings"]) {
			[[BKSProcessAssertion alloc] initWithPID:app.pid flags:BKSProcessAssertionFlagPreventSuspend | BKSProcessAssertionFlagAllowIdleSleep | BKSProcessAssertionFlagPreventThrottleDownCPU | BKSProcessAssertionFlagWantsForegroundResourcePriority reason:BKSProcessAssertionReasonContinuous name:kBKSBackgroundModeContinuous withHandler:nil];
		}
	}
}

%end
%end

%group Apps
%hook UIApplication

- (void)_deactivateForReason:(int)reason notify:(BOOL)notify {
	if (![[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		%orig;
	}
}

%end
%end

%ctor {
	[[HBTSPlusProviderController sharedInstance] loadProviders];

	if (IN_SPRINGBOARD) {
		%init(SpringBoard);
	} else {
		%init(Apps);
	}
}
