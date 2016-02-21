#import "HBTSPlusProviderBackgroundingManager.h"
#import <FrontBoard/FBApplicationProcess.h>
#import <FrontBoard/FBScene.h>
#import <FrontBoard/FBSceneClient.h>
#import <FrontBoard/FBSceneClientProvider.h>
#import <FrontBoard/FBSceneManager.h>
#import <FrontBoard/FBSMutableSceneSettings.h>
#import <FrontBoard/FBSSceneSettings.h>
#import <FrontBoard/FBSSceneSettingsDiff.h>

@implementation HBTSPlusProviderBackgroundingManager

+ (void)putAppWithIdentifier:(NSString *)appIdentifier intoBackground:(BOOL)backgrounded {
	FBScene *scene = [[%c(FBSceneManager) sharedInstance] sceneWithIdentifier:appIdentifier];

	id<FBSceneClientProvider> clientProvider = [scene clientProvider];
	id<FBSceneClient> client = [scene client];

	FBSMutableSceneSettings *sceneSettings = [scene.settings mutableCopy];
	sceneSettings.backgrounded = backgrounded;

	if (!sceneSettings) {
		return;
	}

	FBSSceneSettingsDiff *sceneSettingsDiff = [%c(FBSSceneSettingsDiff) diffFromSettings:scene.settings toSettings:sceneSettings];

	[clientProvider beginTransaction];
	[client host:scene didUpdateSettings:sceneSettings withDiff:sceneSettingsDiff transitionContext:0 completion:nil];
	[clientProvider endTransaction];
}

@end
