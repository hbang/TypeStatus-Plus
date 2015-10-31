#include "HBTSPlusRootListController.h"

@implementation HBTSPlusRootListController {
	UIStatusBarStyle _statusBarStyle;
	UIBarStyle _navigationBarStyle;
}

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
	return [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	_statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	self.realNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.226f green:0.157f blue:0.251f alpha:1.00f];
	_navigationBarStyle = self.realNavigationController.navigationBar.barStyle;
	self.realNavigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle];
	self.realNavigationController.navigationBar.barTintColor = nil;
	self.realNavigationController.navigationBar.barStyle = _navigationBarStyle;
}

@end
