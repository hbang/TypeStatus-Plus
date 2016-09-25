#import "HBTSPlusProviderController.h"
#import "HBTSPlusProviderController+Private.h"
#import <AssertionServices/BKSProcessAssertion.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplicationController.h>

@interface SBLaunchAppListener : NSObject

- (instancetype)initWithBundleIdentifier:(NSString *)bundleIdentifier handlerBlock:(id)block;

@end

%group Apps
%hook UIApplication

- (void)_deactivateForReason:(int)reason notify:(BOOL)notify {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		notify = NO;
	}

	%orig;
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

%end
%end

void launchApps() {
	// TODO: maybe we could spread each one out a few seconds to avoid thrashing
	// the cpu?
	for (NSString *bundleIdentifier in [HBTSPlusProviderController sharedInstance].appsRequiringBackgroundSupport) {
		HBLogDebug(@"launching %@", bundleIdentifier);
		[(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleIdentifier suspended:YES];

		(void)[[%c(SBLaunchAppListener) alloc] initWithBundleIdentifier:bundleIdentifier handlerBlock:^{
			SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];

			(void)[[BKSProcessAssertion alloc] initWithPID:application.pid flags:BKSProcessAssertionFlagPreventSuspend | BKSProcessAssertionFlagPreventThrottleDownCPU | BKSProcessAssertionFlagWantsForegroundResourcePriority reason:BKSProcessAssertionReasonContinuous name:kBKSBackgroundModeContinuous withHandler:nil];
		}];
	}
}

%ctor {
	[[HBTSPlusProviderController sharedInstance] loadProviders];

	if (IN_SPRINGBOARD) {
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			// wait 10 seconds just to ensure most stuff is out of the way
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * 10)), dispatch_get_main_queue(), ^{
				launchApps();
			});
		}];
	} else {
		%init(Apps);
	}
}
