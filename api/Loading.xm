#import "HBTSPlusProviderController.h"
#import <SpringBoard/SBApplication.h>
#import <AssertionServices/BKSProcessAssertion.h>
#import <SpringBoard/SpringBoard.h>

@interface SBApplication (Backgrounding)

@property (nonatomic, retain) BKSProcessAssertion *processAssertion;

@end

%hook SBApplication

%property (nonatomic, retain) BKSProcessAssertion *processAssertion;

- (BOOL)shouldAutoLaunchOnBootOrInstall {
	return [[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier];
}

- (BOOL)supportsContinuousBackgroundMode {
	return [[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier];
}

- (BOOL)_shouldAutoLaunchForVoIP {
	return [[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier];
}

- (BOOL)supportsVOIPBackgroundMode {
	return [[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier];
}

- (id)initWithApplicationInfo:(id)arg1 bundle:(id)arg2 infoDictionary:(id)arg3 entitlements:(id)arg4 usesVisibiliyOverride:(BOOL)arg5 {
	if ((self = %orig)) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC * 2)), dispatch_get_main_queue(), ^{
			self.processAssertion = [[%c(BKSProcessAssertion) alloc] initWithBundleIdentifier:self.bundleIdentifier flags:39 reason:(7 | 11 | 12 | 10000 | 10003 | 10005 | 10006) name:@"TypeStatus Plus" withHandler:^{
				HBLogDebug(@"kept alive: %@", [self.processAssertion valid] ? @"TRUE" : @"FALSE");
			}];
		});
	}
	return self;
}

%end

%ctor {
	if (!IN_SPRINGBOARD) {
		return;
	}

	[[HBTSPlusProviderController sharedInstance] loadProviders];

	%init;
}
