#include "HBTSPlusMessengerRootListController.h"

@implementation HBTSPlusMessengerRootListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"Messenger";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.hb_appearanceSettings.tintColor = [UIColor colorWithRed:0.016f green:0.584f blue:0.988f alpha:1.00f];
	self.hb_appearanceSettings.invertedNavigationBar = YES;
}

@end
