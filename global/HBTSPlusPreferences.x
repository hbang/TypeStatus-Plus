#import "HBTSPlusPreferences.h"

// enabled
static NSString *const kHBTSPlusPreferencesEnabledKey = @"Enabled";

// general
static NSString *const kHBTSPlusShowUnreadCountKey = @"ShowUnreadCount";
static NSString *const kHBTSPlusUnreadCountAppPrefixKey = @"UnreadCountApp-";

static NSString *const kHBTSPlusPreferencesShowInForegroundKey = @"ShowInForeground";

// alerts
static NSString *const kHBTSPlusPreferencesGlobalAlertTypeKey = @"GlobalAlertType";

static NSString *const kHBTSPlusPreferencesWakeWhenLockedKey = @"WakeWhenLocked";

static NSString *const kHBTSPlusPreferencesTapToOpenModeKey = @"TapToOpenMode";

static NSString *const kHBTSPlusPreferencesVibrateOnLockScreenKey = @"VibrateOnLockScreen";
static NSString *const kHBTSPlusPreferencesVibrateOnHomeScreenKey = @"VibrateOnHomeScreen";
static NSString *const kHBTSPlusPreferencesVibrateInAppsKey = @"VibrateInApps";

static NSString *const kHBTSPlusPreferencesShowBannersOnLockScreenKey = @"ShowBannersOnLockScreen";
static NSString *const kHBTSPlusPreferencesShowBannersOnHomeScreenKey = @"ShowBannersOnHomeScreen";
static NSString *const kHBTSPlusPreferencesShowBannersInAppsKey = @"ShowBannersInApps";

static NSString *const kHBTSPlusPreferencesKeepAllBulletinsKey = @"KeepAllBulletins";
static NSString *const kHBTSPlusPreferencesUseAppIconKey = @"UseAppIcon";

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

		NSString *unreadCountMessagesAppKey = [kHBTSPlusUnreadCountAppPrefixKey stringByAppendingString:@"com.apple.MobileSMS"];

		if (!_preferences[unreadCountMessagesAppKey]) {
			_preferences[unreadCountMessagesAppKey] = @YES;
		}

		//enabled
		[_preferences registerBool:&_enabled default:YES forKey:kHBTSPlusPreferencesEnabledKey];

		// general
		[_preferences registerBool:&_showUnreadCount default:YES forKey:kHBTSPlusShowUnreadCountKey];
		[_preferences registerBool:&_showWhenInForeground default:NO forKey:kHBTSPlusPreferencesShowInForegroundKey];

		[_preferences registerBool:&_messagesListTypingIndicators default:YES forKey:@"MessagesShowListTypingIndicators"];
		[_preferences registerBool:&_messagesHighlightFailed default:YES forKey:@"MessagesHighlightFailedMessages"];

		// alerts
		[_preferences registerInteger:(NSInteger *)&_alertType default:HBTSPlusAlertTypeOverlay forKey:kHBTSPlusPreferencesGlobalAlertTypeKey];

		[_preferences registerBool:&_wakeWhenLocked default:YES forKey:kHBTSPlusPreferencesWakeWhenLockedKey];

		[_preferences registerInteger:(NSInteger *)&_tapToOpenMode default:HBTSTapToOpenModeOpen forKey:kHBTSPlusPreferencesTapToOpenModeKey];

		[_preferences registerBool:&_vibrateOnLockScreen default:NO forKey:kHBTSPlusPreferencesVibrateOnLockScreenKey];
		[_preferences registerBool:&_vibrateOnHomeScreen default:YES forKey:kHBTSPlusPreferencesVibrateOnHomeScreenKey];
		[_preferences registerBool:&_vibrateInApps default:YES forKey:kHBTSPlusPreferencesVibrateInAppsKey];

		[_preferences registerBool:&_showBannersOnLockScreen default:YES forKey:kHBTSPlusPreferencesShowBannersOnLockScreenKey];
		[_preferences registerBool:&_showBannersOnHomeScreen default:NO forKey:kHBTSPlusPreferencesShowBannersOnHomeScreenKey];
		[_preferences registerBool:&_showBannersInApps default:NO forKey:kHBTSPlusPreferencesShowBannersInAppsKey];

		[_preferences registerBool:&_keepAllBulletins default:NO forKey:kHBTSPlusPreferencesKeepAllBulletinsKey];
		[_preferences registerBool:&_useAppIcon default:YES forKey:kHBTSPlusPreferencesUseAppIconKey];
	}
	return self;
}

- (BOOL)providerIsEnabled:(NSString *)appIdentifier {
	// TODO: these keys should be prefixed
	return _preferences[appIdentifier] ? ((NSNumber *)_preferences[appIdentifier]).boolValue : YES;
}

- (NSArray <NSString *> *)unreadCountApps {
	// if this isn’t even enabled, just return an empty array
	if (!_showUnreadCount) {
		return @[];
	}

	NSMutableArray <NSString *> *apps = [NSMutableArray array];

	// loop over all preference keys
	for (NSString *key in _preferences.dictionaryRepresentation.allKeys) {
		// if the key has the prefix and is YES, add it to the array
		if ([key hasPrefix:kHBTSPlusUnreadCountAppPrefixKey] && [_preferences boolForKey:key default:NO]) {
			[apps addObject:[key substringFromIndex:kHBTSPlusUnreadCountAppPrefixKey.length]];
		}
	}

	return apps;
}

- (void)registerPreferenceChangeBlock:(HBPreferencesChangeCallback)callback {
	[_preferences registerPreferenceChangeBlock:callback];
}

@end
