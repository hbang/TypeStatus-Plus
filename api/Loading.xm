#import "HBTSPlusProviderController.h"

@interface SBApplication : UIApplication

- (NSString *)bundleIdentifier;

@end

%hook SBApplication

- (BOOL)supportsVOIPBackgroundMode {
	for (NSString *identifier in [HBTSPlusProviderController sharedInstance].appsRequiringBackgroundSupport) {
		if ([[self bundleIdentifier] isEqualToString:identifier]) {
			return YES;
		}
	}
	return %orig;
}

%end

%ctor {
	[[HBTSPlusProviderController sharedInstance] loadProviders];
}
