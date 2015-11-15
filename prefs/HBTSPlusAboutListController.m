#import "HBTSPlusAboutListController.h"

@implementation HBTSPlusAboutListController

+ (NSString *)hb_specifierPlist {
	return @"About";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.235f green:0.671f blue:0.855f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end