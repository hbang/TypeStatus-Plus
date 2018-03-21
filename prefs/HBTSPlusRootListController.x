#include "HBTSPlusRootListController.h"
#import <BulletinBoard/BBSettingsGateway.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <CepheiPrefs/HBSupportController.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIImage+Private.h>

@implementation HBTSPlusRootListController

#pragma mark - HBListController

+ (NSString *)hb_shareText {
	return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"SHARE_TEXT", @"Root", [NSBundle bundleForClass:self], @"Default text for sharing the tweak. %@ is the device type (ie, iPhone)."), [UIDevice currentDevice].localizedModel];
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"https://typestatus.com/plus/"];
}

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

#pragma mark - PSListController

- (void)viewDidLoad {
	[super viewDidLoad];

	HBAppearanceSettings *appearance = [[HBAppearanceSettings alloc] init];
	appearance.tintColor = [UIColor colorWithRed:0.094f green:0.412f blue:0.325f alpha:1];
	appearance.navigationBarTintColor = [UIColor colorWithWhite:0.8f alpha:1];
	appearance.navigationBarBackgroundColor = [UIColor colorWithWhite:0.055f alpha:1];
	appearance.navigationBarTitleColor = [UIColor whiteColor];
	appearance.statusBarTintColor = [UIColor colorWithWhite:1 alpha:0.7f];
	appearance.translucentNavigationBar = NO;
	appearance.tableViewCellTextColor = [UIColor whiteColor];
	appearance.tableViewCellBackgroundColor = [UIColor colorWithWhite:0.055f alpha:1];
	appearance.tableViewCellSeparatorColor = [UIColor colorWithWhite:0.12f alpha:1];
	appearance.tableViewCellSelectionColor = [UIColor colorWithWhite:0.149f alpha:1];
	appearance.tableViewBackgroundColor = [UIColor colorWithWhite:0.089f alpha:1];
	self.hb_appearanceSettings = appearance;

	UIImage *headerLogo = [UIImage imageNamed:@"headerlogo" inBundle:self.bundle];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:headerLogo];
}

- (NSMutableArray <PSSpecifier *> *)specifiers {
	NSMutableArray <PSSpecifier *> *specifiers = [super specifiers];

	for (PSSpecifier *specifier in specifiers) {
		if ([specifier.identifier isEqualToString:@"AlertsCell"]) {
			if (!specifier.properties[@"BBSECTION_INFO_KEY"]) {
				[[NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/NotificationsSettings.bundle"] load];
				specifier.detailControllerClass = %c(BulletinBoardAppDetailController);

				BBSettingsGateway *gateway = [[BBSettingsGateway alloc] init];

				[gateway getSectionInfoForSectionID:@"ws.hbang.typestatusplus.app" withCompletion:^(BBSectionInfo *sectionInfo) {
					if (sectionInfo) {
						specifier.properties[@"BBSECTION_INFO_KEY"] = sectionInfo;
					}
				}];
			}

			break;
		}
	}

	return specifiers;
}

#pragma mark - Callbacks

- (void)showSupportEmailController {
	UIViewController *viewController = (UIViewController *)[HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:@"ws.hbang.typestatusplus"];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end
