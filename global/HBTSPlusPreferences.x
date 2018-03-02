#import "HBTSPlusPreferences.h"

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

		NSString *unreadCountMessagesAppKey = @"UnreadCountApp-com.apple.MobileSMS";

		if (!_preferences[unreadCountMessagesAppKey]) {
			_preferences[unreadCountMessagesAppKey] = @YES;
		}

		//enabled
		[_preferences registerBool:&_enabled default:YES forKey:@"Enabled"];

		// general
		[_preferences registerBool:&_showUnreadCount default:YES forKey:@"ShowUnreadCount"];
		[_preferences registerBool:&_showWhenInForeground default:NO forKey:@"ShowInForeground"];

		[_preferences registerBool:&_messagesListTypingIndicators default:YES forKey:@"MessagesShowListTypingIndicators"];
		[_preferences registerBool:&_messagesHighlightFailed default:YES forKey:@"MessagesHighlightFailedMessages"];

		// alerts
		[_preferences registerInteger:(NSInteger *)&_alertType default:HBTSPlusAlertTypeOverlay forKey:@"GlobalAlertType"];

		[_preferences registerBool:&_wakeWhenLocked default:YES forKey:@"WakeWhenLocked"];

		[_preferences registerInteger:(NSInteger *)&_tapToOpenMode default:HBTSPlusTapToOpenModeOpen forKey:@"TapToOpenMode"];

		[_preferences registerBool:&_vibrateOnLockScreen default:NO forKey:@"VibrateOnLockScreen"];
		[_preferences registerBool:&_vibrateInApps default:YES forKey:@"VibrateInApps"];

		[_preferences registerInteger:(NSInteger *)&_keepBulletinsMode default:NO forKey:@"KeepAllBulletins"];
		[_preferences registerBool:&_useAppIcon default:YES forKey:@"UseAppIcon"];
	}
	return self;
}

- (BOOL)isProviderEnabled:(NSString *)appIdentifier {
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
		if ([key hasPrefix:@"UnreadCountApp-"] && [_preferences boolForKey:key]) {
			[apps addObject:[key substringFromIndex:15]];
		}
	}

	return apps;
}

- (void)registerPreferenceChangeBlock:(HBPreferencesChangeCallback)callback {
	[_preferences registerPreferenceChangeBlock:callback];
}

@end
