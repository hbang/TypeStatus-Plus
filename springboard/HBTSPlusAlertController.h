@class HBTSNotification;

@interface HBTSPlusAlertController : NSObject

+ (void)sendNotification:(HBTSNotification *)notification;
+ (void)hide;

@end
