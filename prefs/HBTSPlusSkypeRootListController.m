#include "HBTSPlusSkypeRootListController.h"

@implementation HBTSPlusSkypeRootListController

+ (NSString *)hb_specifierPlist {
	return @"Skype";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.016f green:0.675f blue:0.953f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end
