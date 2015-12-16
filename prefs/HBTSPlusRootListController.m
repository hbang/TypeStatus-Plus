#include "HBTSPlusRootListController.h"
#import <UIKit/UIImage+Private.h>
#import <CepheiPrefs/HBSupportController.h>

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

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:0.094 green:0.412 blue:0.325 alpha:1.00];
}

+ (UIColor *)hb_navigationBarTintColor {
	return [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:1.00];
}

+ (BOOL)hb_invertedNavigationBar {
	return YES;
}

+ (BOOL)hb_translucentNavigationBar {
	return YES;
}

+ (UIColor *)hb_tableViewCellTextColor {
	return [UIColor whiteColor];
}

+ (UIColor *)hb_tableViewCellBackgroundColor {
	return [UIColor colorWithRed:0.055 green:0.055 blue:0.055 alpha:1.00];
}

+ (UIColor *)hb_tableViewCellSeparatorColor {
	return [UIColor colorWithRed:0.047 green:0.047 blue:0.047 alpha:1.00];
}

+ (UIColor *)hb_tableViewBackgroundColor {
	return [UIColor colorWithRed:0.075 green:0.075 blue:0.075 alpha:1.00];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self _updateHandlers];

	UIImage *headerLogo = [UIImage imageNamed:@"headerlogo" inBundle:[NSBundle bundleForClass:self.class]];
	self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:headerLogo] autorelease];
	self.navigationItem.titleView.alpha = 0.0;

	[self performSelector:@selector(animateIconAlpha) withObject:nil afterDelay:0.5];
}

- (void)animateIconAlpha {
	[UIView animateWithDuration:0.5 animations:^{
		self.navigationItem.titleView.alpha = 1;
	} completion:nil];
}

- (void)showSupportEmailController {
	UIViewController *viewController = (UIViewController *)[HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:@"com.tweakbattles.chrysalis"];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Update state

- (void)_updateHandlers {
	/*HBTSPlusProviderController *providerController = [HBTSPlusProviderController sharedInstance];
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

		specifier.controllerLoadAction = @selector(lazyLoadBundle:);

		[newSpecifiers addObject:specifier];
	}

	HBLogInfo(@"The specifiers loaded into preference are: %@", newSpecifiers);

	if (newSpecifiers.count > 0) {
		[self removeSpecifierID:@"ProvidersNoneInstalledGroupCell"];
		[self insertContiguousSpecifiers:newSpecifiers afterSpecifierID:@"ProvidersGroupCell" animated:YES];
	} else {
		[self removeSpecifierID:@"ProvidersGroupCell"];
	}

	HBLogDebug(@"This is a log to test out if something is run or if this is where it crashes ");*/
}

#pragma mark - Memory management

- (void)dealloc {
	[_providers release];

	[super dealloc];
}

@end
