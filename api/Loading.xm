#import "HBTSPlusProviderBackgroundingManager.h"
#import "HBTSPlusProviderController.h"
#import <AssertionServices/BKSProcessAssertion.h>
#import <FrontBoard/FBApplicationProcess.h>
#import <FrontBoard/FBProcess.h>
#import <FrontBoard/FBScene.h>
#import <FrontBoard/FBSceneClient.h>
#import <FrontBoard/FBSceneClientProvider.h>
#import <FrontBoard/FBSceneManager.h>
#import <FrontBoard/FBSMutableSceneSettings.h>
#import <FrontBoard/FBSSceneSettings.h>
#import <FrontBoard/FBSSceneSettingsDiff.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <UIKit/UIApplicationSceneSettings.h>
#import <UIKit/UIMutableApplicationSceneSettings.h>

%hook SBApplication

- (BOOL)supportsContinuousBackgroundMode {
	%log;
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		HBLogDebug(@"*** whoa %@ is registering for multitasking", self.bundleIdentifier);
		return YES;
	} else {
		HBLogDebug(@"=%i",%orig);
		return %orig;
	}
}

- (void)_transientSuspendForTimerFired:(NSTimer *)timer {
	%log;
	if (![[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		%orig;
	}
}

%end

%hook UIApplication

- (void)_setSuspended:(BOOL)suspended {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		%orig(NO);
	} else {
		%orig;
	}
}

%end

%ctor {
	[[HBTSPlusProviderController sharedInstance] loadProviders];

	if (!IN_SPRINGBOARD) {
		return;
	}

	%init;
}
