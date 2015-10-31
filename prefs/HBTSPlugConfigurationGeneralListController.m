#import "HBTSPlusConfigurationGeneralListController.h"

@implementation HBTSPlusConfigurationGeneralListController

+ (NSString *)hb_specifierPlist {
	return @"ConfigGeneral";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.345f green:0.337f blue:0.839f alpha:1.00f];
}

+ (BOOL)hb_invertedColors {
	return YES;
}

@end