#import "HBTSPlusProviderController.h"
#import "HBTSPlusProviderController+Private.h"
#import "HBTSPlusPreferences.h"
#import "HBTSPlusProvider.h"
#import "HBTSPlusProviderController+Private.h"
#import <MobileCoreServices/LSApplicationProxy.h>

static NSString *const kHBTSPlusProvidersURL = @"file:///Library/TypeStatus/Providers/";

@implementation HBTSPlusProviderController {
	NSMutableSet <HBTSPlusProvider *> *_providers;
	NSMutableSet <NSString *> *_appsRequiringBackgroundSupport;
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
	self = [super init];

	if (self) {
		_providers = [NSMutableSet set];
		_appsRequiringBackgroundSupport = [NSMutableSet set];

		[self loadProviders];
	}
	
	return self;
}

#pragma mark - Loading providers

- (void)loadProviders {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		HBLogInfo(@"loading providers");

		NSURL *providersURL = [NSURL URLWithString:kHBTSPlusProvidersURL].URLByResolvingSymlinksInPath;

		NSError *error = nil;
		NSArray <NSURL *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:providersURL includingPropertiesForKeys:nil options:kNilOptions error:&error];

		if (error) {
			HBLogError(@"failed to access handler directory %@: %@", kHBTSPlusProvidersURL, error.localizedDescription);
			return;
		}

		// anything other than springboard and preferences can be a provider app
		BOOL inApp = !IN_SPRINGBOARD && ![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.Preferences"];

		for (NSURL *directory in contents) {
			NSString *baseName = directory.pathComponents.lastObject;

			// skip anything not ending in .bundle
			if (![baseName hasSuffix:@".bundle"]) {
				continue;
			}

			HBLogInfo(@"loading provider %@", baseName);

			NSBundle *bundle = [NSBundle bundleWithURL:directory];

			if (!bundle) {
				HBLogError(@" --> failed to instantiate the bundle!");
				continue;
			}

			id identifier = bundle.infoDictionary[kHBTSApplicationBundleIdentifierKey];

			if (!identifier) {
				HBLogError(@" --> no app identifier set!");
				continue;
			}

			NSArray <NSString *> *identifiers;

			if ([identifier isKindOfClass:NSString.class]) {
				identifiers = @[ identifier ];
			} else if ([identifier isKindOfClass:NSArray.class]) {
				identifiers = identifier;
			} else {
				HBLogError(@" --> invalid value provided for %@", kHBTSApplicationBundleIdentifierKey);
				continue;
			}

			NSString *appIdentifier;

			if (inApp) {
				if (![identifiers containsObject:[NSBundle mainBundle].bundleIdentifier]) {
					continue;
				}

				appIdentifier = [NSBundle mainBundle].bundleIdentifier;
			} else {
				NSMutableArray <NSString *> *knownIdentifiers = [NSMutableArray array];

				for (NSString *identifier in identifiers) {
					LSApplicationProxy *proxy = [LSApplicationProxy applicationProxyForIdentifier:identifier];

					if (proxy.isInstalled) {
						HBLogDebug(@" --> provider app %@ is installed", identifier);
						[knownIdentifiers addObject:identifier];
					}
				}

				// if the app isn’t installed, don’t bother loading
				if (knownIdentifiers.count == 0) {
					HBLogDebug(@" --> no supported apps installed. not loading");
					continue;
				}

				appIdentifier = knownIdentifiers[0];
			}

			[bundle load];

			if (!bundle.principalClass) {
				HBLogError(@" --> no principal class set!");
				continue;
			}

			if (((NSNumber *)bundle.infoDictionary[kHBTSKeepApplicationAliveKey]).boolValue) {
				[_appsRequiringBackgroundSupport addObjectsFromArray:identifiers];
			}

			HBTSPlusProvider *provider = [[bundle.principalClass alloc] init];
			provider.appIdentifier = appIdentifier;
			[_providers addObject:provider];

			if (!provider) {
				HBLogError(@" --> failed to initialise provider class %@", identifier);
				continue;
			}
		}
	});
}

#pragma mark - Properties

- (NSSet *)providers {
	return _providers;
}

#pragma mark - Backgrounding

- (NSSet *)appsRequiringBackgroundSupport {
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
	HBLogWarn(@"-[HBTSPlusProviderController providerIsEnabled:] is deprecated. call -[HBTSPlusProvider isEnabled] instead");
	return provider.isEnabled;
}

@end
