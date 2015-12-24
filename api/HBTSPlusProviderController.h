static NSString *const kTypeStatusPlusIdentifierString = @"HBTSApplicationBundleIdentifier";
static NSString *const kTypeStatusPlusBackgroundingString = @"HBTSKeepApplicationAlive";

@interface HBTSPlusProviderController : NSObject

@property (nonatomic, retain) NSMutableArray *providers, *appsRequiringBackgroundSupport;

- (BOOL)applicationWithIdentifierRequiresBackgrounding:(NSString *)identifier;

+ (instancetype)sharedInstance;

- (void)loadProviders;

@end
