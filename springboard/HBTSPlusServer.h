@class CPDistributedMessagingCenter;

@interface HBTSPlusServer : NSObject

@property (nonatomic, retain) CPDistributedMessagingCenter *_distributedCenter;

+ (instancetype)sharedInstance;

- (NSDictionary *)receivedGetUnreadCountMessage:(NSString *)message;

- (NSDictionary *)recievedShowBannersMessage:(NSString *)message;

@end
