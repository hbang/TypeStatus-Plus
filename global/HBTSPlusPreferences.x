#import "HBTSPlusPreferences.h"
#import <Cephei/HBPreferences.h>

// enabled
static NSString *const kHBTSPlusPreferencesEnabledKey = @"Enabled";

// general
static NSString *const kHBTSPlusShowUnreadCountKey = @"ShowUnreadCount";
static NSString *const kHBTSPlusUnreadCountAppPrefixKey = @"UnreadCountApp-";

static NSString *const kHBTSPlusPreferencesShowInForegroundKey = @"ShowInForeground";

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

		// show unread count for messages by default
		_preferences.defaults[[kHBTSPlusUnreadCountAppPrefixKey stringByAppendingString:@"com.apple.MobileSMS"]] = @YES;

		//enabled
		[_preferences registerBool:&_enabled default:YES forKey:kHBTSPlusPreferencesEnabledKey];

		// general
		[_preferences registerBool:&_showUnreadCount default:YES forKey:kHBTSPlusShowUnreadCountKey];

		[_preferences registerBool:&_showWhenInForeground default:NO forKey:kHBTSPlusPreferencesShowInForegroundKey];

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
	// TODO: these keys should be prefixed
	return _preferences[appIdentifier] ? [_preferences[appIdentifier] boolValue] : YES;
}

- (NSArray <NSString *> *)unreadCountApps {
	// if this isn’t even enabled, just return an empty array
	if (!_showUnreadCount) {
		return @[];
	}

	NSMutableArray <NSString *> *apps = [NSMutableArray array];

	// TODO: HBPreferences should have a dictionary representation thing with
	// default keys in it too. this is intentionally ugly so i fix it sometime,
	// probably, maybe
	NSArray <NSString *> *keys = _preferences.dictionaryRepresentation.allKeys;

	if (![keys containsObject:[kHBTSPlusUnreadCountAppPrefixKey stringByAppendingString:@"com.apple.MobileSMS"]]) {
		keys = [keys arrayByAddingObject:[kHBTSPlusUnreadCountAppPrefixKey stringByAppendingString:@"com.apple.MobileSMS"]];
	}

	for (NSString *key in keys) {
		if ([_preferences boolForKey:key default:NO]) {
			[apps addObject:[key substringFromIndex:kHBTSPlusUnreadCountAppPrefixKey.length]];
		}
	}

	return apps;
}

#pragma mark - Memory management

- (void)dealloc {
	[_preferences release];

	[super dealloc];
}

@end
