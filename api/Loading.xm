#import "HBTSPlusProviderBackgroundingManager.h"
#import "HBTSPlusProviderController.h"
#import <AssertionServices/BKSProcessAssertion.h>
#import <AssertionServices/BKSProcessAssertionClient.h>
#import <BaseBoard/BSMutableSettings.h>
#import <SpringBoard/SBApplication.h>

%hook SBAppSwitcherModel

- (void)_appActivationStateDidChange:(NSNotification *)notification {
	%orig;

	SBApplication *app = notification.object;

	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:app.bundleIdentifier]) {
		BSMutableSettings *settings = [[app valueForKey:@"_stateSettings"] valueForKey:@"_settings"];

		if ((settings.allSettings.count > 1 && [settings boolForSetting:BSSettingTypeThisIsAReminderToFillOutTheseEnumNames]) || [app valueForKey:@"_activationSettings"]) {
			__unused BKSProcessAssertion *assertion = [[BKSProcessAssertion alloc] initWithPID:app.pid flags:BKSProcessAssertionFlagPreventSuspend | BKSProcessAssertionFlagAllowIdleSleep | BKSProcessAssertionFlagPreventThrottleDownCPU | BKSProcessAssertionFlagWantsForegroundResourcePriority reason:BKSProcessAssertionReasonContinuous name:kBKSBackgroundModeContinuous withHandler:^(BOOL valid) {
				HBLogDebug(@"valid? %i", valid);

				NSMapTable *assertionHandlers = [[BKSProcessAssertionClient sharedInstance] valueForKey:@"_assertionHandlersByIdentifier"];

				for (BKSProcessAssertion *currentAssertion in assertionHandlers.objectEnumerator) {
					if (((NSNumber *)[currentAssertion valueForKey:@"_pid"]).intValue == app.pid) {
						HBLogDebug(@"new assertion: %@", [currentAssertion valueForKey:@"_reason"]);
					}
				}
			}];
		}
	}
}

%end

%ctor {
	[[HBTSPlusProviderController sharedInstance] loadProviders];

	if (IN_SPRINGBOARD) {
		%init;
	}
}
