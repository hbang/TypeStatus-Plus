@interface HBTSPlusTapToOpenController : NSObject

@property (nonatomic, retain) NSString *appIdentifier;
@property (nonatomic, retain) NSURL *actionURL;

+ (instancetype)sharedInstance;

- (NSDictionary *)receivedStatusBarTappedMessage:(NSString *)message;

@end
