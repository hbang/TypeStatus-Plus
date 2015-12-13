#include "HBTSPlusSnapchatRootListController.h"

@implementation HBTSPlusSnapchatRootListController

+ (NSString *)hb_specifierPlist {
	return @"Snapchat";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:1.0f green:0.8f blue:0.0f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end
