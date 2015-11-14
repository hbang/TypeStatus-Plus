#include "HBTSPlusRootListController.h"
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>
#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <Preferences/PSSpecifier.h>

@implementation HBTSPlusRootListController {
	NSArray *_providers;
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

/*+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.345f green:0.337f blue:0.839f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}*/

- (void)viewDidLoad {
	[super viewDidLoad];

	UIImage *icon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlus.bundle"] pathForResource:@"icon" ofType:@"png"]];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:icon];
}

- (NSArray *)specifiers {
    NSArray *specifiers = [super specifiers];
    [self _updateHandlers];
    return specifiers;
}

#pragma mark - Update state

- (void)_updateHandlers {
	HBTSPlusProviderController *providerController = [HBTSPlusProviderController sharedInstance];
	[providerController loadProviders];

	_providers = [providerController.providers copy];

	HBLogDebug(@"providers array is %@", _providers);

	NSMutableArray *newSpecifiers = [NSMutableArray array];

	for (HBTSPlusProvider *provider in _providers) {
		PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:provider.name target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:Nil cell:PSLinkCell edit:Nil];

		HBLogDebug(@"The preference bundle is %@, preference class is %@", provider.preferencesBundle, provider.preferencesClass);

		if (!provider.preferencesBundle ||  !provider.preferencesClass || !provider.appIdentifier) {
			HBLogError(@"Necessary details not provided for %@", provider.name);
			continue;
		}

		specifier.properties = [@{
			PSIDKey: provider.appIdentifier,
			PSBundleIsControllerKey: @YES,
			PSLazilyLoadedBundleKey: provider.preferencesBundle.bundlePath,
			PSDetailControllerClassKey: provider.preferencesClass,
			PSLazyIconAppID: provider.appIdentifier,
			PSLazyIconLoading: @YES
		} mutableCopy];

		[newSpecifiers addObject:specifier];
	}

	HBLogInfo(@"The specificers loaded into preference are: %@", newSpecifiers);

	if (newSpecifiers.count > 0) {
		[self removeSpecifierID:@"ProvidersNoneInstalledGroupCell"];
		[self insertContiguousSpecifiers:newSpecifiers afterSpecifierID:@"ProvidersGroupCell" animated:YES];
	} else {
		[self removeSpecifierID:@"ProvidersGroupCell"];
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[_providers release];

	[super dealloc];
}

@end
