#import <SpringBoard/SBApplication.h>
#import <FrontBoard/FBProcess.h>
#import <SpringBoard/SpringBoard.h>
#import <AssertionServices/BKSProcessAssertion.h>
#import <FrontBoard/FBProcessManager.h>
#import "../HBTSPlusPreferences.h"

@interface FBProcessManager (Backgrounding)

@property (nonatomic, retain) BKSProcessAssertion *processAssertion;

@end

%hook FBProcessManager

%property (nonatomic, retain) BKSProcessAssertion *processAssertion;

- (void)noteProcessDidExit:(FBProcess *)process {
	%orig;

	if (![[%c(HBTSPlusPreferences) sharedInstance] enabled]) {
		return;
	}

	NSString *bundleIdentifier = process.bundleIdentifier;
	HBLogDebug(@"Process identifier just shut is %@", bundleIdentifier);

	dispatch_async(dispatch_get_main_queue(), ^{
			[(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleIdentifier suspended:YES];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * 2)), dispatch_get_main_queue(), ^{
		self.processAssertion = [[%c(BKSProcessAssertion) alloc] initWithBundleIdentifier:bundleIdentifier flags:39 reason:(7 | 11 | 12 | 10000 | 10003 | 10005 | 10006) name:@"TypeStatus Plus" withHandler:^{
			HBLogDebug(@"kept alive: %@", [self.processAssertion valid] ? @"TRUE" : @"FALSE");
		}];
	});
}

%end
