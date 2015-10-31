#import "HBTSPlusConfigurationWhatsappListController.h"

@implementation HBTSPlusConfigurationWhatsappListController

+ (NSString *)hb_specifierPlist {
	return @"ConfigWhatsapp";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.196f green:0.851f blue:0.310f alpha:1.00f];
}

+ (BOOL)hb_invertedColors {
	return YES;
}

@end