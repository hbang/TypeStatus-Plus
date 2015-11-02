#import "HBTSPlusAboutListController.h"

@implementation HBTSPlusAboutListController

+ (NSString *)hb_specifierPlist {
	return @"About";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.196f green:0.831f blue:0.306f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end