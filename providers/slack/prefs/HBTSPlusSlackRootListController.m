#include "HBTSPlusSlackRootListController.h"

@implementation HBTSPlusSlackRootListController

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.659f green:0.110f blue:0.294f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end
