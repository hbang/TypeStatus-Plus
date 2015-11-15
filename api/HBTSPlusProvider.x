#import "HBTSPlusProvider.h"
#import "../typestatus-private/HBTSStatusBarAlertServer.h"

@implementation HBTSPlusProvider

+ (void)showNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	HBLogDebug(@"About to show notification %@ %@", title, content);
	[%c(HBTSStatusBarAlertServer) sendAlertWithIconName:iconName title:title content:content];
}

+ (void)hideNotification {
	HBLogDebug(@"About to hide notification");
	[%c(HBTSStatusBarAlertServer) hide];
}

@end
