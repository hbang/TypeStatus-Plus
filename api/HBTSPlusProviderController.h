static NSString *const kTypeStatusPlusIdentifierString = @"HBTSApplicationBundleIdentifier";
static NSString *const kTypeStatusPlusBackgroundingString = @"HBTSKeepApplicationAlive";

@class HBTSPlusProvider;

@interface HBTSPlusProviderController : NSObject

@property (nonatomic, retain) NSMutableArray *providers, *appsRequiringBackgroundSupport;

- (BOOL)applicationWithIdentifierRequiresBackgrounding:(NSString *)identifier;

+ (instancetype)sharedInstance;

- (void)loadProviders;

- (HBTSPlusProvider *)providerWithAppIdentifier:(NSString *)appIdentifier;

- (BOOL)providerIsEnabled:(HBTSPlusProvider *)provider;

@end
