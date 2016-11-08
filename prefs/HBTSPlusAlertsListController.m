#import "HBTSPlusBannersListController.h"
#include <notify.h>

@implementation HBTSPlusBannersListController

+ (NSString *)hb_specifierPlist {
	return @"Banners";
}

#pragma mark - Callbacks

- (void)testAlert {
	notify_post("ws.hbang.typestatus/TestTyping");
}

@end
