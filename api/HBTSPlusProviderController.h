NS_ASSUME_NONNULL_BEGIN

/**
 * TODO: Document
 */
static NSString *const kHBTSApplicationBundleIdentifierKey = @"HBTSApplicationBundleIdentifier";

/**
 * TODO: Document
 */
static NSString *const kHBTSKeepApplicationAliveKey = @"HBTSKeepApplicationAlive";

@class HBTSPlusProvider;

/**
 * TODO: Document
 */
@interface HBTSPlusProviderController : NSObject

/**
 * TODO: Document
 */
+ (instancetype)sharedInstance;

/**
 * TODO: Document
 */
@property (nonatomic, retain, readonly) NSMutableArray *providers;

/**
 * TODO: Document
 */
- (HBTSPlusProvider *)providerWithAppIdentifier:(NSString *)appIdentifier;

/**
 * TODO: Document
 */
- (BOOL)providerIsEnabled:(HBTSPlusProvider *)provider;

/**
 * TODO: Document
 */
- (BOOL)applicationWithIdentifierRequiresBackgrounding:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
