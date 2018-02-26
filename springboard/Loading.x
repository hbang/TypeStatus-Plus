#import <AssertionServices/BKSProcessAssertion.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplicationController.h>
#import <TypeStatusProvider/TypeStatusProvider.h>
#import "../typestatus-private/HBTSProviderController+Private.h"

@interface SBLaunchAppListener : NSObject

- (instancetype)initWithBundleIdentifier:(NSString *)bundleIdentifier handlerBlock:(id)block;

@end

void launchApps() {
	NSUInteger i = 0;

	// loop over each app we must launch
	for (NSString *bundleIdentifier in [HBTSProviderController sharedInstance].appsRequiringBackgroundSupport) {
		// wait i * 2 seconds before launching, so we don’t thrash cpu as much
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * i * 2)), dispatch_get_main_queue(), ^{
			HBLogDebug(@"launching %@", bundleIdentifier);
			[(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleIdentifier suspended:YES];

			(void)[[%c(SBLaunchAppListener) alloc] initWithBundleIdentifier:bundleIdentifier handlerBlock:^{
				SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];

				(void)[[BKSProcessAssertion alloc] initWithPID:application.pid flags:BKSProcessAssertionFlagPreventSuspend | BKSProcessAssertionFlagPreventThrottleDownCPU | BKSProcessAssertionFlagWantsForegroundResourcePriority reason:BKSProcessAssertionReasonContinuous name:kBKSBackgroundModeContinuous withHandler:nil];
			}];
		});

		i++;
	}
}

%ctor {
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		// wait 10 seconds just to ensure most stuff is out of the way
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * 10)), dispatch_get_main_queue(), ^{
			launchApps();
		});
	}];
}
