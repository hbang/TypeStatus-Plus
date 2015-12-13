@interface HBTSStatusBarAlertServer : NSObject

+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content;

+ (void)hide;

@end
