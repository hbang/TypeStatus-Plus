#import "HBTSPlusPreferences.h"
#import <Cephei/HBPreferences.h>

// enabled
static NSString *const kHBTSPlusPreferencesEnabledKey = @"Enabled";

// general
static NSString *const kHBTSPlusUnreadNotificationAppIdentifierKey = @"UnreadNotificationAppBundleIdentifier";

static NSString *const kHBTSPlusPreferencesShowWhenInForegroundKey = @"ShowInForeground";

// banners
static NSString *const kHBTSPlusPreferencesKeepAllBulletinsKey = @"KeepAllBulletins";
static NSString *const kHBTSPlusPreferencesUseAppIconKey = @"UseAppIcon";

static NSString *const kHBTSPlusPreferencesShowBannersOnLockScreenKey = @"ShowBannersOnLockScreen";
static NSString *const kHBTSPlusPreferencesShowBannersOnHomeScreenKey = @"ShowBannersOnHomeScreen";
static NSString *const kHBTSPlusPreferencesShowBannersInAppsKey = @"ShowBannersInApps";

// vibrations
static NSString *const kHBTSPlusPreferencesVibrateOnLockScreenKey = @"VibrateOnLockScreen";
static NSString *const kHBTSPlusPreferencesVibrateOnHomeScreenKey = @"VibrateOnHomeScreen";
static NSString *const kHBTSPlusPreferencesVibrateInAppsKey = @"VibrateInApps";

@implementation HBTSPlusPreferences {
	HBPreferences *_preferences;
}

+ (instancetype)sharedInstance {
	static HBTSPlusPreferences *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		_preferences = [[HBPreferences alloc] initWithIdentifier:@"ws.hbang.typestatusplus"];

		//enabled
		[_preferences registerBool:&_enabled default:YES forKey:kHBTSPlusPreferencesEnabledKey];

		// general
		[_preferences registerObject:&_applicationUsingUnreadCount default:@"com.apple.MobileSMS" forKey:kHBTSPlusUnreadNotificationAppIdentifierKey];

		[_preferences registerBool:&_showWhenInForeground default:NO forKey:kHBTSPlusPreferencesShowWhenInForegroundKey];

		// banners
		[_preferences registerBool:&_keepAllBulletins default:NO forKey:kHBTSPlusPreferencesKeepAllBulletinsKey];
		[_preferences registerBool:&_useAppIcon default:YES forKey:kHBTSPlusPreferencesUseAppIconKey];

		[_preferences registerBool:&_showBannersOnLockScreen default:YES forKey:kHBTSPlusPreferencesShowBannersOnLockScreenKey];
		[_preferences registerBool:&_showBannersOnHomeScreen default:NO forKey:kHBTSPlusPreferencesShowBannersOnHomeScreenKey];
		[_preferences registerBool:&_showBannersInApps default:NO forKey:kHBTSPlusPreferencesShowBannersInAppsKey];

		// vibrations
		[_preferences registerBool:&_vibrateOnLockScreen default:NO forKey:kHBTSPlusPreferencesVibrateOnLockScreenKey];
		[_preferences registerBool:&_vibrateOnHomeScreen default:YES forKey:kHBTSPlusPreferencesVibrateOnHomeScreenKey];
		[_preferences registerBool:&_vibrateInApps default:YES forKey:kHBTSPlusPreferencesVibrateInAppsKey];
	}
	return self;
}

- (BOOL)providerIsEnabled:(NSString *)appIdentifier {
	return _preferences[appIdentifier] ? [_preferences[appIdentifier] boolValue] : YES;
}

#pragma mark - Memory management

- (void)dealloc {
	[_preferences release];

	[super dealloc];
}

@end
