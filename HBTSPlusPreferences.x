#import "HBTSPlusPreferences.h"
#import <Cephei/HBPreferences.h>

static NSString *const kHBTSPlusPreferencesEnabledKey = @"Enabled";
static NSString *const kHBTSPlusPreferencesShowNotificationsEverywhereKey = @"ShowNotificationsEverywhere";
static NSString *const kHBTSPlusPreferencesHapticFeedbackKey = @"HapticFeedback";
static NSString *const kHBTSPlusPreferencesShowWhenInForegroundKey = @"ShowInForeground";
static NSString *const kHBTSPlusPreferencesUseTSPIconKey = @"UseTSPIcon";

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

		[_preferences registerBool:&_enabled default:YES forKey:kHBTSPlusPreferencesEnabledKey];
		[_preferences registerBool:&_showNotificationsEverywhere default:NO forKey:kHBTSPlusPreferencesShowNotificationsEverywhereKey];
		[_preferences registerBool:&_hapticFeedback default:YES forKey:kHBTSPlusPreferencesHapticFeedbackKey];
		[_preferences registerBool:&_showWhenInForeground default:NO forKey:kHBTSPlusPreferencesShowWhenInForegroundKey];
		[_preferences registerBool:&_useTSPIcon default:NO forKey:kHBTSPlusPreferencesUseTSPIconKey];
	}
	return self;
}

- (NSString *)applicationUsingUnreadCount {
	return _preferences[@"UnreadNotificationAppBundleIdentifier"] ?: @"com.apple.MobileSMS";
}

- (BOOL)providerIsEnabled:(NSString *)appIdentifier {
	return _preferences[appIdentifier] ? [_preferences[appIdentifier] boolValue] : YES;
}

@end
