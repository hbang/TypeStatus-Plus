#include "HBTSPlusMusicRootListController.h"

@implementation HBTSPlusMusicRootListController

+ (NSString *)hb_shareText {
	return @"TypeStatus Plus allows me to see songs changing at a glance. Available now on the BigBoss repo.";
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"https://typestatus.com/"];
}

+ (NSString *)hb_specifierPlist {
	return @"Music";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.635f green:0.314f blue:0.682f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end
