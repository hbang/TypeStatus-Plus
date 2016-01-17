@interface HBTSPlusTapToOpenController : NSObject

@property (nonatomic, retain) NSString *appIdentifier;

+ (instancetype)sharedInstance;

- (NSDictionary *)receivedStatusBarTappedMessage:(NSString *)message;

@end
