#import "HBTSPlusProvider.h"
#import "../typestatus-private/HBTSStatusBarAlertController.h"

@implementation HBTSPlusProvider

- (void)showNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	[[%c(HBTSStatusBarAlertController) sharedInstance] showWithIconName:iconName title:title content:content];
}

- (void)hideNotification {
	[[%c(HBTSStatusBarAlertController) sharedInstance] hide];
}

@end
