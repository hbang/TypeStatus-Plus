static NSString *const kHBTSApplicationBundleIdentifierKey = @"HBTSApplicationBundleIdentifier";
static NSString *const kHBTSKeepApplicationAliveKey = @"HBTSKeepApplicationAlive";

@class HBTSPlusProvider;

@interface HBTSPlusProviderController : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, retain, readonly) NSMutableArray *providers;

- (HBTSPlusProvider *)providerWithAppIdentifier:(NSString *)appIdentifier;
- (BOOL)providerIsEnabled:(HBTSPlusProvider *)provider;

- (BOOL)applicationWithIdentifierRequiresBackgrounding:(NSString *)identifier;

@end
