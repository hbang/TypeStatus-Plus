#include "HBTSPlusMessengerRootListController.h"

@implementation HBTSPlusMessengerRootListController

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.016f green:0.584f blue:0.988f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end
