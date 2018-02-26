#import <TypeStatusProvider/TypeStatusProvider.h>

@interface HBTSStatusBarAlertServer : NSObject

+ (void)sendNotification:(HBTSNotification *)notification;
+ (void)hide;

@end
