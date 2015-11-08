#import "HBTSPlusProvider.h"

static NSString *const kTypeStatusPlusIdentifierString = @"HBTSApplicationBundleIdentifier";
static NSString *const kTypeStatusPlusBackgroundingString = @"HBTSKeepApplicationAlive";

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
	NSString *providerPath = @"/Library/TypeStatus/Providers";
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL URLWithString:providerPath] includingPropertiesForKeys:nil options:kNilOptions error:&error];

	if (error) {
		HBLogError(@"failed to access handler directory %@: %@", providerPath, error.localizedDescription);
		return;
	}

	identifiers = @[];

	for (NSURL *directory in contents) {
		NSString *baseName = directory.pathComponents.lastObject;

		HBLogInfo(@"loading %@", baseName);

		NSBundle *bundle = [NSBundle bundleWithURL:directory];

		if (!bundle) {
			HBLogError(@"failed to load bundle for handler %@", baseName);
			return;
		}

		[bundle load];

		if (!bundle.principalClass) {
			HBLogError(@"no principal class for handler %@", baseName);
			return;
		}

		if (bundle.infoDictionary[kTypeStatusPlusIdentifierString] && [bundle.infoDictionary[kTypeStatusPlusBackgroundingString] boolValue]) {
			identifiers = [identifiers arrayByAddingObject:bundle.infoDictionary[kTypeStatusPlusIdentifierString]];
		}

		HBTSPlusProvider *provider = [[[bundle.principalClass alloc] init] autorelease];

		if (!provider) {
			HBLogError(@"TypeStatusPlusProvider: failed to initialise principal class for %@", baseName);
			return;
		}

	}
}