#include "HBTSPlusWhatsappRootListController.h"

@implementation HBTSPlusWhatsappRootListController

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.200f green:0.851f blue:0.314f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end
