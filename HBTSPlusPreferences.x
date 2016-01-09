#import "HBTSPlusPreferences.h"
#import <Cephei/HBPreferences.h>

static NSString *const kHBTSPlusPreferencesEnabledKey = @"Enabled";
static NSString *const kHBTSPlusPreferencesShowNotificationsEverywhereKey = @"ShowNotificationsEverywhere";
static NSString *const kHBTSPlusPreferencesHapticFeedback = @"HapticFeedback";

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
		[_preferences registerBool:&_hapticFeedback default:YES forKey:kHBTSPlusPreferencesHapticFeedback];
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
