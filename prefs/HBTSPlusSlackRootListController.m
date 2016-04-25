#include "HBTSPlusSlackRootListController.h"

@implementation HBTSPlusSlackRootListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"Slack";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.hb_appearanceSettings.tintColor = [UIColor colorWithRed:0.659f green:0.110f blue:0.294f alpha:1.00f];
	self.hb_appearanceSettings.invertedNavigationBar = YES;
}

@end
