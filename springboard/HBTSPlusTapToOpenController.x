#import "HBTSPlusTapToOpenController.h"
#import "HBTSPlusPreferences.h"
#import <FrontBoardServices/FBSSystemService.h>
#import <SpringBoard/SBWorkspaceApplication.h>
#import <SpringBoard/SBWorkspaceApplicationTransitionContext.h>
#import "../typestatus-private/HBTSStatusBarAlertServer.h"

static BOOL overrideBreadcrumbHax;

@implementation HBTSPlusTapToOpenController

+ (instancetype)sharedInstance {
	static HBTSPlusTapToOpenController *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (NSDictionary *)receivedStatusBarTappedMessage:(NSString *)message {
	HBLogDebug(@"Status bar tapped—recieved notification");

	dispatch_async(dispatch_get_main_queue(), ^{
		HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

		switch (preferences.tapToOpenMode) {
			case HBTSPlusTapToOpenModeNothing:
				break;
			
			case HBTSPlusTapToOpenModeOpen:
				// if we got a url, open that, or fall back to just opening the app like normal
				[self _openURL:_actionURL bundleIdentifier:_appIdentifier];
				break;
			
			case HBTSPlusTapToOpenModeDismiss:
				[HBTSStatusBarAlertServer hide];
				break;
		}
	});

	return nil;
}

- (void)_openURL:(NSURL *)url bundleIdentifier:(NSString *)bundleIdentifier {
	// get the frontboard system service and then create a port for the message we’re about to send
	FBSSystemService *systemService = [FBSSystemService sharedService];
	mach_port_t port = [systemService createClientPort];

	overrideBreadcrumbHax = YES;

	[systemService openURL:url application:bundleIdentifier options:@{
		FBSOpenApplicationOptionKeyUnlockDevice: @YES
	} clientPort:port withResult:nil];
}

@end

%hook SBMainDisplaySceneManager

- (BOOL)_shouldBreadcrumbApplication:(SBWorkspaceApplication *)launchedApplication withTransitionContext:(SBWorkspaceApplicationTransitionContext *)transitionContext {
	if (overrideBreadcrumbHax) {
		overrideBreadcrumbHax = NO;

		// get the app we’re about to switch from
		SBWorkspaceApplication *previousApp = [transitionContext previousApplicationForLayoutRole:SBLayoutRoleMainApp];

		// if there was an app (not the home screen), and it’s not the same as the one we’re launching,
		// override to enable breadcrumbs
		return previousApp && ![launchedApplication.bundleIdentifier isEqualToString:previousApp.bundleIdentifier];
	}

	return %orig;
}

%end
