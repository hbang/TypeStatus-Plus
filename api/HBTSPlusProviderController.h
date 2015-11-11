static NSString *const kTypeStatusPlusIdentifierString = @"HBTSApplicationBundleIdentifier";
static NSString *const kTypeStatusPlusBackgroundingString = @"HBTSKeepApplicationAlive";

@interface HBTSPlusProviderController : NSObject

@property (nonatomic, retain) NSMutableArray *providers, *appsRequiringBackgroundSupport;

+ (instancetype)sharedInstance;

- (void)loadProviders;

@end