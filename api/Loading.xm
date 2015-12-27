#import "HBTSPlusProviderController.h"
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SpringBoard.h>

%hook SBApplication

- (BOOL)shouldAutoRelaunchAfterExit {
	return [[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier];
}

%end

%ctor {
	if (!IN_SPRINGBOARD) {
		return;
	}

	[[HBTSPlusProviderController sharedInstance] loadProviders];

	%init;
}
