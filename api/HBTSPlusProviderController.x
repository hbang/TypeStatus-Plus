#import "HBTSPlusProviderController.h"
#import "HBTSPlusPreferences.h"
#import "HBTSPlusProvider.h"
#import "HBTSPlusProviderController+Private.h"
#import <MobileCoreServices/LSApplicationProxy.h>

static NSString *const kHBTSPlusProvidersURL = @"file:///Library/TypeStatus/Providers/";

@implementation HBTSPlusProviderController {
	NSMutableArray *_appsRequiringBackgroundSupport;
}

+ (instancetype)sharedInstance {
	static HBTSPlusProviderController *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

#pragma mark - Initialization

- (instancetype)init {
	if (self = [super init]) {
		_providers = [[NSMutableArray alloc] init];
		_appsRequiringBackgroundSupport = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark - Loading providers

- (void)loadProviders {
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		HBLogDebug(@"loading providers");

		NSURL *providersURL = [NSURL URLWithString:kHBTSPlusProvidersURL].URLByResolvingSymlinksInPath;

		NSError *error = nil;
		NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:providersURL includingPropertiesForKeys:nil options:kNilOptions error:&error];

		if (error) {
			HBLogError(@"failed to access handler directory %@: %@", kHBTSPlusProvidersURL, error.localizedDescription);
			return;
		}

		// anything other than springboard and preferences can be a provider app
		BOOL inApp = !IN_SPRINGBOARD && ![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.Preferences"];

		for (NSURL *directory in contents) {
			NSString *baseName = directory.pathComponents.lastObject;

			NSBundle *bundle = [NSBundle bundleWithURL:directory];

			if (!bundle) {
				HBLogError(@"failed to load bundle for provider %@", baseName);
				continue;
			}

			id identifier = bundle.infoDictionary[kHBTSApplicationBundleIdentifierKey];

			if (!identifier) {
				HBLogError(@"no app identifier set for provider %@", baseName);
				continue;
			}

			NSArray *identifiers;

			if ([identifier isKindOfClass:NSString.class]) {
				identifiers = @[ identifier ];
			} else if ([identifier isKindOfClass:NSArray.class]) {
				identifiers = identifier;
			} else {
				HBLogError(@"huh, what kind of class is %@?", identifier);
				continue;
			}

			NSString *appIdentifier;

			if (inApp) {
				if (![identifiers containsObject:[NSBundle mainBundle].bundleIdentifier]) {
					continue;
				}

				appIdentifier = [NSBundle mainBundle].bundleIdentifier;
			} else {
				NSMutableArray *knownIdentifiers = [NSMutableArray array];

				for (NSString *identifier in identifiers) {
					HBLogDebug(@"checking %@", identifier);
					LSApplicationProxy *proxy = [LSApplicationProxy applicationProxyForIdentifier:identifier];

					if (proxy.isInstalled) {
						HBLogDebug(@" --> is installed");
						[knownIdentifiers addObject:identifier];
					}
				}

				// if the app isn’t installed, don’t bother loading
				if (knownIdentifiers.count == 0) {
					HBLogDebug(@"skipping – no supported apps are installed");
					continue;
				}

				appIdentifier = knownIdentifiers[0];
			}

			[bundle load];

			if (!bundle.principalClass) {
				HBLogError(@"no principal class for provider %@", baseName);
				continue;
			}

			if (((NSNumber *)bundle.infoDictionary[kHBTSKeepApplicationAliveKey]).boolValue) {
				[_appsRequiringBackgroundSupport addObjectsFromArray:identifiers];
				HBLogDebug(@"The bundle %@ requires backgrounding support.", baseName);
			}

			HBTSPlusProvider *provider = [[bundle.principalClass alloc] init];
			provider.appIdentifier = appIdentifier;
			[_providers addObject:provider];

			if (!provider) {
				HBLogError(@"failed to initialise principal class %@ for %@", identifier, baseName);
				continue;
			}

			HBLogDebug(@"The bundle %@ was successfully and completely loaded", baseName);
		}
	});
}

#pragma mark - Backgrounding

- (NSMutableArray *)appsRequiringBackgroundSupport {
	return _appsRequiringBackgroundSupport;
}

- (BOOL)applicationWithIdentifierRequiresBackgrounding:(NSString *)appIdentifier {
	return [_appsRequiringBackgroundSupport containsObject:appIdentifier];
}

#pragma mark - Preferences

- (HBTSPlusProvider *)providerWithAppIdentifier:(NSString *)appIdentifier {
	for (HBTSPlusProvider *provider in _providers) {
		if ([provider.appIdentifier isEqualToString:appIdentifier]) {
			return provider;
		}
	}
	return nil;
}

- (BOOL)providerIsEnabled:(HBTSPlusProvider *)provider {
	HBTSPlusPreferences *preferences = [%c(HBTSPlusPreferences) sharedInstance];

	if (!preferences.enabled) {
		return NO;
	}

	if (provider.preferencesBundle && provider.preferencesClass) {
		// the provider manages its own preferences. return YES
		return YES;
	} else {
		return [preferences providerIsEnabled:provider.appIdentifier];
	}
}

@end
