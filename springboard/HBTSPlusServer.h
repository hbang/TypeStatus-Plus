@class CPDistributedMessagingCenter;

@interface HBTSPlusServer : NSObject

@property (nonatomic, retain) CPDistributedMessagingCenter *_distributedCenter;

+ (instancetype)sharedInstance;

- (NSDictionary *)receivedGetUnreadCountMessage:(NSString *)message;

@end
