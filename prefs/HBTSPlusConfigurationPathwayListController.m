#import "HBTSPlusConfigurationPathwayListController.h"

@implementation HBTSPlusConfigurationPathwayListController

+ (NSString *)hb_specifierPlist {
	return @"ConfigPathway";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.537f green:0.549f blue:0.565f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

@end