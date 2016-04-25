#include "HBTSPlusSnapchatRootListController.h"

@implementation HBTSPlusSnapchatRootListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"Snapchat";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.hb_appearanceSettings.tintColor = [UIColor colorWithRed:1.0f green:0.8f blue:0.0f alpha:1.00f];
	self.hb_appearanceSettings.invertedNavigationBar = YES;
}

@end
