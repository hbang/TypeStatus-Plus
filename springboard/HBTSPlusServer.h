@class CPDistributedMessagingCenter;

@interface HBTSPlusServer : NSObject

+ (instancetype)sharedInstance;

- (NSDictionary *)receivedGetUnreadCountMessage:(NSString *)message;

- (NSDictionary *)recievedShowBannersMessage:(NSString *)message;

@end
