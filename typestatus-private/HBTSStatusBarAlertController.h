@class UIStatusBar;

@interface HBTSStatusBarAlertController : NSObject

- (void)showWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content;

- (void)hide;

@end
