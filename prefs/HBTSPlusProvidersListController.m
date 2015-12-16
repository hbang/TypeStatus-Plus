#import "HBTSPlusProvidersListController.h"
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>
#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <Preferences/PSSpecifier.h>

@implementation HBTSPlusProvidersListController {
	NSArray *_providers;
}

+ (NSString *)hb_specifierPlist {
	return @"Providers";
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self _updateHandlers];
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];

	[self _updateHandlers];
}

#pragma mark - Update state

- (void)_updateHandlers {
	HBTSPlusProviderController *providerController = [HBTSPlusProviderController sharedInstance];
	[providerController loadProviders];

	_providers = [providerController.providers copy];

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

		specifier.controllerLoadAction = @selector(lazyLoadBundle:);

		[newSpecifiers addObject:specifier];
	}

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
