@class CPDistributedMessagingCenter;

@interface HBTSPlusServer : NSObject

+ (instancetype)sharedInstance;

- (NSDictionary *)recievedShowBannersMessage:(NSString *)message;

@end
