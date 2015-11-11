#import "HBTSPlusConfigurationPathwayListController.h"
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>
#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <Preferences/PSSpecifier.h>

@implementation HBTSPlusConfigurationPathwayListController {
	NSArray *_providers;
}

+ (NSString *)hb_specifierPlist {
	return @"ConfigPathway";
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.537f green:0.549f blue:0.565f alpha:1.00f];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
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