#import "HBTSPlusAlertsListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSSystemPolicyForApp.h>
#import <Preferences/PSTableCell.h>
#include <notify.h>

@implementation HBTSPlusAlertsListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"Alerts";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self _setUpSpecifiers];
}

#pragma mark - PSListController

- (void)reloadSpecifiers {
	[super reloadSpecifiers];
	[self _setUpSpecifiers];
}

- (void)showController:(PSViewController *)controller animate:(BOOL)animated {
	// remove the tint from the notifications vc, because it derps out the alert style section
	if ([controller isKindOfClass:%c(BulletinBoardAppDetailController)]) {
		HBAppearanceSettings *appearanceSettings = [self.hb_appearanceSettings copy];
		appearanceSettings.tintColor = nil;
		((PSListController *)controller).hb_appearanceSettings = appearanceSettings;

		[UISwitch appearanceWhenContainedInInstancesOfClasses:@[ controller.class ]].onTintColor = self.hb_appearanceSettings.tintColor;
	}

	[super showController:controller animate:animated];
}

#pragma mark - Setup

- (void)_setUpSpecifiers {
	// if we don’t already have a notifications cell
	if (![self specifierForID:@"NOTIFICATIONS"]) {
		// construct a system notification settings cell
		PSSystemPolicyForApp *policy = [[PSSystemPolicyForApp alloc] initWithBundleIdentifier:@"ws.hbang.typestatusplus.app"];

		// this usually returns an array of specifiers, including the “allow [app] to access” group
		// specifier, which we kinda don’t want. after this method does its thing, notificationSpecifier
		// will be non-nil, and we can just add that
		[policy specifiersForPolicyOptions:PSSystemPolicyOptionsNotifications force:YES];
		
		[self insertSpecifier:policy.notificationSpecifier afterSpecifierID:@"NotificationsGroup"];
	}
}

#pragma mark - Callbacks

- (void)testAlert {
	notify_post("ws.hbang.typestatusplus/TestNotification");
}

@end
