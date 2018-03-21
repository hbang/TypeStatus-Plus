#import "HBTSPlusProvidersListController.h"
#import "HBTSPlusProviderLinkTableCell.h"
#import "HBTSPlusProviderSwitchTableCell.h"
#import "HBTSProvider+TypeStatusPlusAdditions.h"
#import "../typestatus-private/HBTSProviderController+Private.h"
#import <Preferences/PSSpecifier.h>

@implementation HBTSPlusProvidersListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"Providers";
}

#pragma mark - PSListController

- (NSMutableArray <PSSpecifier *> *)specifiers {
	NSMutableArray <PSSpecifier *> *specifiers = [super specifiers];
	[self _updateHandlers];
	return specifiers;
}

#pragma mark - Update state

- (void)_updateHandlers {
	HBTSProviderController *providerController = [HBTSProviderController sharedInstance];
	
	[providerController _loadProvidersWithCompletion:^{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			// turn the providers set into an array and sort by name
			NSArray <HBTSProvider *> *providers = [providerController.providers.allObjects sortedArrayUsingComparator:^NSComparisonResult (HBTSProvider *item1, HBTSProvider *item2) {
				return [item1.name caseInsensitiveCompare:item2.name];
			}];

			NSMutableArray *newSpecifiers = [NSMutableArray array];

			for (HBTSProvider *provider in providers) {
				BOOL isLink = provider.preferencesBundle && provider.preferencesClass;
				BOOL isBackgrounded = [providerController doesApplicationIdentifierRequireBackgrounding:provider.appIdentifier];

				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:provider.name target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:Nil cell:isLink ? PSLinkCell : PSSwitchCell edit:Nil];

				if (isLink) {
					specifier.properties = [@{
						PSCellClassKey: HBTSPlusProviderLinkTableCell.class,
						PSIDKey: provider.appIdentifier,
						PSDetailControllerClassKey: provider.preferencesClass,
						PSLazilyLoadedBundleKey: provider.preferencesBundle.bundlePath,
						PSLazyIconAppID: provider.appIdentifier,
						PSLazyIconLoading: @YES,
						HBTSPlusProviderCellIsBackgroundedKey: @(isBackgrounded)
					} mutableCopy];

					specifier->action = @selector(specifierCellTapped:);
				} else {
					specifier.properties = [@{
						PSCellClassKey: HBTSPlusProviderSwitchTableCell.class,
						PSIDKey: provider.appIdentifier,
						PSDefaultValueKey: @YES,
						PSDefaultsKey: @"ws.hbang.typestatusplus",
						PSKeyNameKey: provider.appIdentifier,
						PSValueChangedNotificationKey: @"ws.hbang.typestatusplus/ReloadPrefs",
						PSLazyIconAppID: provider.appIdentifier,
						PSLazyIconLoading: @YES,
						HBTSPlusProviderCellIsBackgroundedKey: @(isBackgrounded)
					} mutableCopy];
				}

				[newSpecifiers addObject:specifier];
			}

			// jump back to the main queue to add our new specifiers
			dispatch_async(dispatch_get_main_queue(), ^{
				if (newSpecifiers.count > 0) {
					[self removeSpecifierID:@"ProvidersNoneInstalledGroupCell"];
					[self insertContiguousSpecifiers:newSpecifiers afterSpecifierID:@"ProvidersGroupCell" animated:NO];
				} else {
					[self removeSpecifierID:@"ProvidersGroupCell"];
				}
			});
		});
	}];
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
	NSString *title = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"FAILED_TO_LOAD_PREFS_TITLE", @"Providers", self.bundle, @"Title used on an alert when a provider’s preferences fail to load."), name];
	NSString *message = NSLocalizedStringFromTableInBundle(@"FAILED_TO_LOAD_PREFS_BODY", @"Providers", self.bundle, @"Body used on an alert when a provider’s preferences fail to load.");
	NSString *ok = NSLocalizedStringFromTableInBundle(@"OK", @"Localizable", [NSBundle bundleForClass:UIView.class], nil);

	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:ok style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alertController animated:YES completion:nil];
}

@end
