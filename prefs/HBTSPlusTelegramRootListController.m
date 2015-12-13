#include "HBTSPlusTelegramRootListController.h"

@implementation HBTSPlusTelegramRootListController

+ (NSString *)hb_specifierPlist {
	return @"Telegram";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.173f green:0.631f blue:0.859f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end
