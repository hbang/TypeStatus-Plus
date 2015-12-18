#import "HBTSPlusProviderController.h"
#import "HBTSPlusProvider.h"

@implementation HBTSPlusProviderController

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
	static dispatch_once_t predicate;
	   dispatch_once(&predicate, ^{

		NSString *providerPath = @"/Library/TypeStatus/Providers";
		NSError *error = nil;
		NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL URLWithString:providerPath] includingPropertiesForKeys:nil options:kNilOptions error:&error];

		if (error) {
			HBLogError(@"failed to access handler directory %@: %@", providerPath, error.localizedDescription);
			return;
		}

		for (NSURL *directory in contents) {
			NSString *baseName = directory.pathComponents.lastObject;

			NSBundle *bundle = [NSBundle bundleWithURL:directory];

			if (!bundle) {
				HBLogError(@"failed to load bundle for provider %@", baseName);
				continue;
			}

			/*if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:bundle.infoDictionary[kTypeStatusPlusIdentifierString]]) {
				continue;
			}*/

			[bundle load];

			if (!bundle.principalClass) {
				HBLogError(@"no principal class for provider %@", baseName);
				continue;
			}

			if (bundle.infoDictionary[kTypeStatusPlusIdentifierString] && [bundle.infoDictionary[kTypeStatusPlusBackgroundingString] boolValue]) {
				[_appsRequiringBackgroundSupport addObject:bundle.infoDictionary[kTypeStatusPlusIdentifierString]];
				HBLogInfo(@"The bundle %@ requires backgrounding support", baseName);
			}

			HBTSPlusProvider *provider = [[[bundle.principalClass alloc] init] autorelease];
			provider.appIdentifier = bundle.infoDictionary[kTypeStatusPlusIdentifierString];
			[_providers addObject:provider];

			if (!provider) {
				HBLogError(@"TypeStatusPlusProvider: failed to initialise principal class for %@", baseName);
				continue;
			}

			HBLogInfo(@"The bundle %@ was successfully and completely loaded", baseName);
		}
	});
}

@end
