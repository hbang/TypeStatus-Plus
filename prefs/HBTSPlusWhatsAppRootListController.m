#import "HBTSPlusWhatsAppRootListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>

@implementation HBTSPlusWhatsAppRootListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"WhatsApp";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.hb_appearanceSettings.tintColor = [UIColor colorWithRed:0.200f green:0.851f blue:0.314f alpha:1.00f];
	self.hb_appearanceSettings.invertedNavigationBar = YES;
}

@end
