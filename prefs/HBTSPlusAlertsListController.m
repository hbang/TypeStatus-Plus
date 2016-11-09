#import "HBTSPlusAlertsListController.h"
#include <notify.h>

@implementation HBTSPlusAlertsListController

+ (NSString *)hb_specifierPlist {
	return @"Alerts";
}

#pragma mark - Callbacks

- (void)testAlert {
	notify_post("ws.hbang.typestatusplus/TestNotification");
}

@end
