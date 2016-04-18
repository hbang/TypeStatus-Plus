static NSString *const kTypeStatusPlusIdentifierString = @"HBTSApplicationBundleIdentifier";
static NSString *const kTypeStatusPlusBackgroundingString = @"HBTSKeepApplicationAlive";

@class HBTSPlusProvider;

@interface HBTSPlusProviderController : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, retain, readonly) NSMutableArray *providers;

- (HBTSPlusProvider *)providerWithAppIdentifier:(NSString *)appIdentifier;
- (BOOL)providerIsEnabled:(HBTSPlusProvider *)provider;

- (BOOL)applicationWithIdentifierRequiresBackgrounding:(NSString *)identifier;

@end
