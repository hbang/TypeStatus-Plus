#import "HBTSPlusProviderController.h"
#import "HBTSPlusProvider.h"

@implementation HBTSPlusProviderController {
	BOOL _hasLoadedProviders;
}

+ (instancetype)sharedInstance {
	static HBTSPlusProviderController *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		_providers = [[NSMutableArray alloc] init];
		_appsRequiringBackgroundSupport = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)loadProviders {

	if (_hasLoadedProviders) {
		HBLogDebug(@"you only load handlers once (YOLHO)");
		return;
	}

	HBLogInfo(@"loading providers");

	_hasLoadedProviders = YES;

	NSString *providerPath = @"/Library/TypeStatus/Providers";
	NSError *error = nil;
	NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL URLWithString:providerPath] includingPropertiesForKeys:nil options:kNilOptions error:&error];

	if (error) {
		HBLogError(@"failed to access handler directory %@: %@", providerPath, error.localizedDescription);
		return;
	}

	for (NSURL *directory in contents) {
		NSString *baseName = directory.pathComponents.lastObject;

		HBLogInfo(@"loading %@", baseName);

		NSBundle *bundle = [NSBundle bundleWithURL:directory];

		HBLogInfo(@"The bundle info is %@", bundle.infoDictionary);

		if (!bundle) {
			HBLogError(@"failed to load bundle for provider %@", baseName);
			continue;
		}

		[bundle load];

		if (!bundle.principalClass) {
			HBLogError(@"no principal class for provider %@", baseName);
			continue;
		}

		if (bundle.infoDictionary[kTypeStatusPlusIdentifierString] && [bundle.infoDictionary[kTypeStatusPlusBackgroundingString] boolValue]) {
			[_appsRequiringBackgroundSupport addObject:bundle.infoDictionary[kTypeStatusPlusIdentifierString]];
			continue;
		}

		HBLogInfo(@"The info dictionary of the bundle just loaded is %@", bundle.infoDictionary);

		HBTSPlusProvider *provider = [[[bundle.principalClass alloc] init] autorelease];
		provider.appIdentifier = bundle.infoDictionary[kTypeStatusPlusIdentifierString];
		[_providers addObject:provider];
		[_appsRequiringBackgroundSupport addObject:provider.appIdentifier];

		if (!provider) {
			HBLogError(@"TypeStatusPlusProvider: failed to initialise principal class for %@", baseName);
			continue;
		}
	}
}

@end