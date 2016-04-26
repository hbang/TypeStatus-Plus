#import "HBTSPlusTelegramRootListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>

@implementation HBTSPlusTelegramRootListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"Telegram";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.hb_appearanceSettings.tintColor = [UIColor colorWithRed:0.173f green:0.631f blue:0.859f alpha:1.00f];
	self.hb_appearanceSettings.invertedNavigationBar = YES;
}

@end
