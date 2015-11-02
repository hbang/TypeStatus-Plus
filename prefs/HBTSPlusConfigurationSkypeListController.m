#import "HBTSPlusConfigurationSkypeListController.h"

@implementation HBTSPlusConfigurationSkypeListController

+ (NSString *)hb_specifierPlist {
	return @"ConfigSkype";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.000f green:0.686f blue:0.941f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end