#import "HBTSPlusProviderBackgroundingManager.h"
#import <FrontBoard/FBSSceneSettings.h>
#import <FrontBoard/FBSMutableSceneSettings.h>
#import <FrontBoard/FBSSceneSettingsDiff.h>
#import <FrontBoard/FBSceneClientProvider.h>
#import <FrontBoard/FBSceneClient.h>
#import <FrontBoard/FBScene.h>
#import <FrontBoard/FBSceneManager.h>
#import <FrontBoard/FBApplicationProcess.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplication.h>

@implementation HBTSPlusProviderBackgroundingManager

+ (void)putAppWithIdentifier:(NSString *)appIdentifier intoBackground:(BOOL)backgrounded {
	SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:appIdentifier];

	FBScene *scene = [application mainScene];
	if (!scene || !scene.settings || !scene.mutableSettings) {
		return;
	}

	FBSMutableSceneSettings *sceneSettings = scene.mutableSettings;
	sceneSettings.backgrounded = backgrounded;
	[scene _applyMutableSettings:sceneSettings withTransitionContext:nil completion:nil];
}

@end
