#import "HBTSPlusAboutListController.h"
#import <Preferences/PSSpecifier.h>
#import <TechSupport/TechSupport.h>

@implementation HBTSPlusAboutListController

+ (NSString *)hb_specifierPlist {
	return @"About";
}

- (void)viewDidLoad {
	[super viewDidLoad];

	TSPackage *package = [[TSPackage alloc] initWithIdentifier:@"ws.hbang.typestatusplus"];

	PSSpecifier *specifier = [self.specifiers lastObject];
	// TODO: needs l10n
	[specifier setProperty:[NSString stringWithFormat:@"%@\n%@", package.name, [NSString stringWithFormat:@"Version: %@", package.version]] forKey:PSFooterTextGroupKey];

}

@end
