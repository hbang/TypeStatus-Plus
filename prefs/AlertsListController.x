#import <BulletinBoard/BBSectionInfo.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#include <notify.h>

extern NSMutableArray <PSSpecifier *> *SpecifiersFromPlist(NSDictionary *plist, PSSpecifier *parentSpecifier, id target, NSString *plistName, NSBundle *bundle, NSString **title, NSString **specifierID, PSListController *listController, NSMutableArray **bundleControllers);

@interface BulletinBoardAppDetailController : PSListController

@end

%hook BulletinBoardAppDetailController

#pragma mark - PSListController

- (NSMutableArray <PSSpecifier *> *)specifiers {
	NSMutableArray <PSSpecifier *> *specifiers = %orig;

	BBSectionInfo *sectionInfo = self.specifier.properties[@"BBSECTION_INFO_KEY"];

	// if this is a settings page for us, and we haven’t already inserted our specifiers, do so
	if (sectionInfo.sectionID && [sectionInfo.sectionID isEqualToString:@"ws.hbang.typestatusplus.app"] && !self.navigationItem.rightBarButtonItem) {
		// get the specifiers from Alerts.plist
		NSBundle *plusBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlus.bundle"];
		NSDictionary *ourSpecifierPlist = [NSDictionary dictionaryWithContentsOfURL:[plusBundle URLForResource:@"Alerts" withExtension:@"plist"]];
		NSString *title = nil;
		NSMutableArray <PSSpecifier *> *ourSpecifiers = SpecifiersFromPlist(ourSpecifierPlist, self.specifier, self, @"Alerts", plusBundle, &title, nil, self, nil);

		// if we’ve been invoked from our own prefs, override the title
		if (self.specifier.properties[@"fromTypeStatus"]) {
			self.title = title;
		}

		// replace the specifiers
		NSMutableArray <PSSpecifier *> *oldSpecifiers = specifiers;
		specifiers = ourSpecifiers;
		[self setValue:specifiers forKey:@"_specifiers"];

		// do our modifications
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"TEST_ALERT", @"Alerts", plusBundle, nil) style:UIBarButtonItemStylePlain target:self action:@selector(typeStatusPlus_testAlert)];

		oldSpecifiers[0].identifier = @"NotificationsGroup";
		oldSpecifiers[0].properties[@"footerText"] = NSLocalizedStringFromTableInBundle(@"NOTIFICATION_CENTER_EXPLANATION", @"Alerts", plusBundle, nil);
		oldSpecifiers[1].name = NSLocalizedStringFromTableInBundle(@"NOTIFICATION_CENTER", @"Alerts", plusBundle, nil);

		// put the bulletin specifiers at our insert point
		PSSpecifier *insertSpecifier = nil;
		
		for (PSSpecifier *specifier in specifiers) {
			if ([specifier.identifier isEqualToString:@"InsertBulletinBoardSpecifiers"]) {
				insertSpecifier = specifier;
				break;
			}
		}

		[self insertContiguousSpecifiers:oldSpecifiers afterSpecifier:insertSpecifier];
		[self removeSpecifier:insertSpecifier];
	}

	return specifiers;
}

#pragma mark - Callbacks

%new - (void)typeStatusPlus_testAlert {
	notify_post("ws.hbang.typestatus/TestTyping");
}

%end

#pragma mark - Constructor

%ctor {
	[[NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/NotificationsSettings.bundle"] load];
	%init;
}
