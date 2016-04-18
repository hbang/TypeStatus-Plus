#import "HBTSPlusProvidersListController.h"
#import "../api/HBTSPlusProviderController.h"
#import "../api/HBTSPlusProviderController+Private.h"
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
		BOOL isLink = provider.preferencesBundle && provider.preferencesClass;

		PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:provider.name target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:Nil cell:isLink ? PSLinkCell : PSSwitchCell edit:Nil];

		if (isLink) {
			specifier.properties = [@{
				PSIDKey: provider.appIdentifier,
				PSDetailControllerClassKey: provider.preferencesClass,
				PSLazilyLoadedBundleKey: provider.preferencesBundle.bundlePath,
				PSIDKey: provider.appIdentifier,
				PSLazyIconAppID: provider.appIdentifier,
				PSLazyIconLoading: @YES,
			} mutableCopy];

			specifier->action = @selector(specifierCellTapped:);
		} else {
			specifier.properties = [@{
				PSIDKey: provider.appIdentifier,
				PSDefaultValueKey: @YES,
				PSDefaultsKey: @"ws.hbang.typestatusplus",
				PSKeyNameKey: provider.appIdentifier,
				PSValueChangedNotificationKey: @"ws.hbang.typestatusplus/ReloadPrefs",
				PSLazyIconAppID: provider.appIdentifier,
				PSLazyIconLoading: @YES
			} mutableCopy];
		}

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
		[self _showBundleLoadErrorForProviderName:specifier.name];
		return;
	}

	if (![providerBundle load]) {
		HBLogError(@"Bundle %@ failed to load", providerBundle);
		[self _showBundleLoadErrorForProviderName:specifier.name];
		return;
	}

	Class providerClass = NSClassFromString(providerClassName);

	if (!providerClass) {
		HBLogError(@"Bundle %@ failed to load: Class %@ doesn't exist", providerBundle, providerClassName);
		[self _showBundleLoadErrorForProviderName:specifier.name];
		return;
	}

	PSListController *listController = [[providerClass alloc] init];
	[self pushController:listController animate:YES];
}

- (void)_showBundleLoadErrorForProviderName:(NSString *)name {
	// TODO: needs l10n
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Couldn’t load the settings for %@ because an error occurred.", name] message:@"Check for updates to TypeStatus Plus and your providers. Contact the developer if this issue persists." preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Memory management

- (void)dealloc {
	[_providers release];

	[super dealloc];
}

@end
