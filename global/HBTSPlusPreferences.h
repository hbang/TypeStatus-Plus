#import <Cephei/HBPreferences.h>

@interface HBTSPlusPreferences : NSObject

@property (nonatomic, readonly) BOOL enabled;

@property (nonatomic, readonly) BOOL showUnreadCount, showWhenInForeground;

@property (nonatomic, readonly) BOOL keepAllBulletins, useAppIcon;

@property (nonatomic, readonly) BOOL showBannersOnLockScreen, showBannersOnHomeScreen, showBannersInApps;

@property (nonatomic, readonly) BOOL vibrateOnLockScreen, vibrateOnHomeScreen, vibrateInApps;

+ (instancetype)sharedInstance;

- (BOOL)providerIsEnabled:(NSString *)appIdentifier;

- (NSArray <NSString *> *)unreadCountApps;

- (void)registerPreferenceChangeBlock:(HBPreferencesChangeCallback)callback;

@end
