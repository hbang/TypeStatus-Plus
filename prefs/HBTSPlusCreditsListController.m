#import "HBTSPlusCreditsListController.h"

@implementation HBTSPlusCreditsListController

+ (NSString *)hb_specifierPlist {
	return @"Credits";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.902f green:0.722f blue:0.000f alpha:1.00f];
}

+ (BOOL)hb_invertedColors {
	return YES;
}

@end