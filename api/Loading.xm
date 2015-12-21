#import "HBTSPlusProviderController.h"

@interface SBApplication : UIApplication

- (NSString *)bundleIdentifier;

@end

%hook SBApplication

- (BOOL)_shouldAutoLaunchOnBootOrInstall {
	HBLogDebug(@"The appsRequiringBackgroundSupport = %@", [HBTSPlusProviderController sharedInstance].appsRequiringBackgroundSupport);
	for (NSString *identifier in [HBTSPlusProviderController sharedInstance].appsRequiringBackgroundSupport) {
		if ([[self bundleIdentifier] isEqualToString:identifier]) {
			return YES;
		}
	}
	return %orig;
}

%end

%ctor {
	if (!IN_SPRINGBOARD) {
		return;
	}

	[[HBTSPlusProviderController sharedInstance] loadProviders];

	%init;
}
