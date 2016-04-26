#import "HBTSPlusAboutListController.h"
#import <Preferences/PSSpecifier.h>
#import <TechSupport/TechSupport.h>

@implementation HBTSPlusAboutListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"About";
}

#pragma mark - PSListController

- (void)viewDidLoad {
	[super viewDidLoad];

	[self _updateVersion];
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];

	[self _updateVersion];
}

#pragma mark - Update state

- (void)_updateVersion {
	TSPackage *package = [[TSPackage alloc] initWithIdentifier:@"ws.hbang.typestatusplus"];

	NSBundle *cepheiBundle = [NSBundle bundleWithPath:@"/Library/Frameworks/CepheiPrefs.framework"];
	NSString *versionString = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"HEADER_VERSION", @"PackageNameHeaderCell", cepheiBundle, @"The subheading containing the package version."), package.version];

	PSSpecifier *specifier = [self specifierForID:@"VersionGroupCell"];
	specifier.properties[PSFooterTextGroupKey] = [NSString stringWithFormat:@"%@\n%@\n© HASHBANG Productions", package.name, versionString];
}

@end
