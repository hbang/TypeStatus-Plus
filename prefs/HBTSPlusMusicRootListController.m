#include "HBTSPlusMusicRootListController.h"

@implementation HBTSPlusMusicRootListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"Music";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.hb_appearanceSettings.tintColor = [UIColor colorWithRed:0.635f green:0.314f blue:0.682f alpha:1.00f];
	self.hb_appearanceSettings.invertedNavigationBar = YES;
}

@end
