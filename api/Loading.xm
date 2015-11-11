#import "HBTSPlusProviderController.h"

NSArray *identifiers;

@interface SBApplication : UIApplication

- (NSString *)bundleIdentifier;

@end

%hook SBApplication

- (BOOL)supportsContinuousBackgroundMode {
	for (NSString *identifier in identifiers) {
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