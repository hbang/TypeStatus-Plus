#import "HBTSPlusProviderController.h"
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>
#import <FrontBoard/FBSSceneSettings.h>
#import <FrontBoard/FBSMutableSceneSettings.h>
#import <FrontBoard/FBSSceneSettingsDiff.h>
#import <FrontBoard/FBSceneClientProvider.h>
#import <FrontBoard/FBSceneClient.h>
#import <FrontBoard/FBScene.h>
#import <FrontBoard/FBSceneManager.h>
#import <UIKit/UIMutableApplicationSceneSettings.h>
#import <FrontBoard/FBApplicationProcess.h>
#import "HBTSPlusProviderBackgroundingManager.h"
#import <UIKit/UIApplicationSceneSettings.h>

@interface FBUIApplicationWorkspaceScene : NSObject

- (NSString *)identifier;

@end

%hook FBUIApplicationWorkspaceScene

- (void)host:(FBScene *)scene didUpdateSettings:(FBSSceneSettings *)sceneSettings withDiff:(FBSSceneSettingsDiff *)diff transitionContext:(id)transitionContext completion:(id)completionBlock {
	// we check that all of these things exist to avoid crashes
	if (scene && scene.identifier && scene.clientProcess && sceneSettings && [sceneSettings isKindOfClass:%c(FBSSceneSettings)]) {
		// check:
		// - app requires backgrounding
		// - the settings that are about to be applied have the app in the background
		// if both of those things are true, we need to take it out of the background
		if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:scene.identifier] && [sceneSettings isBackgrounded]) {
			UIMutableApplicationSceneSettings *mutableSettings = [[sceneSettings mutableCopy] autorelease];
			mutableSettings.backgrounded = NO;

			UIApplicationSceneSettings *settings = [[[%c(UIApplicationSceneSettings) alloc] initWithSettings:mutableSettings] autorelease];

			%orig(scene, settings, arg3, arg4, arg5);
			return;
		}
	}

	%orig;
}

%end

%hook FBApplicationProcess

- (void)killForReason:(NSInteger)integer andReport:(BOOL)report withDescription:(NSString *)description completion:(id)completionBlock {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		[HBTSPlusProviderBackgroundingManager putAppWithIdentifier:self.bundleIdentifier intoBackground:NO];
		return;
	}
	%orig;
}

%end

%hook SBApplication

- (BOOL)shouldAutoRelaunchAfterExit {
	return [[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier] ?: %orig;
}

- (BOOL)_shouldAutoLaunchOnBootOrInstall:(BOOL)shouldAutoLaunch {
	return [[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier] ?: %orig;
}

- (void)processDidLaunch:(FBApplicationProcess *)process {
	%orig;

	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		[(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:self.bundleIdentifier suspended:YES];
		[HBTSPlusProviderBackgroundingManager putAppWithIdentifier:self.bundleIdentifier intoBackground:NO];
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
