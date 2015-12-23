#import "HBTSPlusProvidersListController.h"
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>
#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSViewController.h>

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
			PSDetailControllerClassKey: provider.preferencesClass,
			PSLazilyLoadedBundleKey: provider.preferencesBundle.bundlePath,
			PSIDKey: provider.appIdentifier,
			PSLazyIconAppID: provider.appIdentifier,
			PSLazyIconLoading: @YES,
		} mutableCopy];

		specifier->action = @selector(specifierCellTapped:);

		[newSpecifiers addObject:specifier];
	}

	if (newSpecifiers.count > 0) {
		[self removeSpecifierID:@"ProvidersNoneInstalledGroupCell"];
		[self insertContiguousSpecifiers:newSpecifiers afterSpecifierID:@"ProvidersGroupCell" animated:YES];
	} else {
		[self removeSpecifierID:@"ProvidersGroupCell"];
	}
}

- (void)specifierCellTapped:(PSSpecifier *)specifier {
	NSString *providerClassName = [specifier propertyForKey:PSDetailControllerClassKey];
	NSBundle *providerBundle = [NSBundle bundleWithPath:[specifier propertyForKey:PSLazilyLoadedBundleKey]];

	if (!providerBundle) {
		HBLogError(@"Bundle %@ does not exist", providerBundle);
		[self _showBundleLoadError];
		return;
	}

	if (![providerBundle load]) {
		HBLogError(@"Bundle %@ failed to load", providerBundle);
		[self _showBundleLoadError];
		return;
	}

	Class providerClass = NSClassFromString(providerClassName);

	if (!providerClass) {
		HBLogError(@"Bundle %@ failed to load: Class %@ doesn't exist", providerBundle, providerClassName);
		[self _showBundleLoadError];
		return;
	}

	PSListController *listController = [[providerClass alloc] init];
	[self pushController:listController animate:YES];
}

- (void)_showBundleLoadError {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOCALIZE(@"BUNDLE_LOAD_FAILED", @"")]
}

#pragma mark - Memory management

- (void)dealloc {
	[_providers release];

	[super dealloc];
}

@end