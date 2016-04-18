#import "HBTSPlusProviderBackgroundingManager.h"
#import "HBTSPlusProviderController.h"
#import "HBTSPlusProviderController+Private.h"
#import <AssertionServices/BKSProcessAssertion.h>
#import <AssertionServices/BKSProcessAssertionClient.h>
#import <BaseBoard/BSMutableSettings.h>
#import <SpringBoard/SBApplication.h>
#import <FrontBoard/FBProcess.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplicationController.h>

@interface SBLaunchAppListener : NSObject

- (instancetype)initWithBundleIdentifier:(NSString *)bundleIdentifier handlerBlock:(id)block;

@end

%group SpringBoard
%hook SBUIController

- (void)finishLaunching {
	%orig;

	for (NSString *bundleIdentifier in [HBTSPlusProviderController sharedInstance].appsRequiringBackgroundSupport) {
		[(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleIdentifier suspended:YES];

		[[%c(SBLaunchAppListener) alloc] initWithBundleIdentifier:bundleIdentifier handlerBlock:^{
			SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];

			[[BKSProcessAssertion alloc] initWithPID:application.pid flags:BKSProcessAssertionFlagPreventSuspend | BKSProcessAssertionFlagPreventThrottleDownCPU | BKSProcessAssertionFlagWantsForegroundResourcePriority reason:BKSProcessAssertionReasonContinuous name:kBKSBackgroundModeContinuous withHandler:nil];
		}];
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

- (BOOL)_isLaunchedSuspended {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		return NO;
	}
	return %orig;
}

- (BOOL)isSuspended {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		return NO;
	}
	return %orig;
}

- (BOOL)isSuspendedUnderLock {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		return NO;
	}
	return %orig;
}

- (BOOL)isSuspendedEventsOnly {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		return NO;
	}
	return %orig;
}

- (BOOL)_isActivated {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		return YES;
	}
	return %orig;
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
