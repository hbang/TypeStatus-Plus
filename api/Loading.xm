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

%hook FBApplicationProcess

- (void)killForReason:(NSInteger)integer andReport:(BOOL)report withDescription:(NSString *)description completion:(id)completionBlock {
	%log;
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

%end

%hook SBApplication

- (void)processDidLaunch:(FBApplicationProcess *)process {
	%orig;

	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		[(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:self.bundleIdentifier suspended:YES];
		[HBTSPlusProviderBackgroundingManager putAppWithIdentifier:self.bundleIdentifier intoBackground:NO];
	}
}

%end

%ctor {
	if (!IN_SPRINGBOARD) {
		return;
	}

	[[HBTSPlusProviderController sharedInstance] loadProviders];

	%init;
}
