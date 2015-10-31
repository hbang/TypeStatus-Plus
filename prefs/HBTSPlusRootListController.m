#include "HBTSPlusRootListController.h"

@implementation HBTSPlusRootListController

+ (NSString *)hb_shareText {
	return @"Couldn't be more happy I purchased TypeStatus+, the most advanced way to see who is typing. Available at BigBoss today for only 99 cents!";
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"https://typestatus.com"];
}

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.169f green:0.169f blue:0.169f alpha:1.00f];
}

+ (BOOL)hb_invertedColors {
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	UIImage *icon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlus.bundle"] pathForResource:@"icon" ofType:@"png"]];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:icon];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.navigationItem.titleView = nil;
}

@end
