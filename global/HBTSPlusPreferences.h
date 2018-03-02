#import <Cephei/HBPreferences.h>

typedef NS_ENUM(NSUInteger, HBTSPlusAlertType) {
	HBTSPlusAlertTypeIcon,
	HBTSPlusAlertTypeOverlay
};

typedef NS_ENUM(NSUInteger, HBTSPlusTapToOpenMode) {
	HBTSPlusTapToOpenModeNothing,
	HBTSPlusTapToOpenModeOpen,
	HBTSPlusTapToOpenModeDismiss
};

typedef NS_ENUM(NSUInteger, HBTSPlusKeepBulletinsMode) {
	HBTSPlusKeepBulletinsModeOne,
	HBTSPlusKeepBulletinsModeAll,
	HBTSPlusKeepBulletinsModeForever
};

@interface HBTSPlusPreferences : NSObject

@property (nonatomic, readonly) BOOL enabled;

@property (nonatomic, readonly) BOOL showUnreadCount, showWhenInForeground;
@property (nonatomic, readonly) BOOL messagesListTypingIndicators, messagesHighlightFailed;
@property (nonatomic, readonly) BOOL keepAllBulletins, useAppIcon;
@property (nonatomic, readonly) BOOL wakeWhenLocked;
@property (nonatomic, readonly) BOOL vibrateOnLockScreen, vibrateInApps;

@property (nonatomic, readonly) HBTSPlusAlertType alertType;
@property (nonatomic, readonly) HBTSPlusTapToOpenMode tapToOpenMode;
@property (nonatomic, readonly) HBTSPlusKeepBulletinsMode keepBulletinsMode;

+ (instancetype)sharedInstance;

- (BOOL)isProviderEnabled:(NSString *)appIdentifier;

- (NSArray <NSString *> *)unreadCountApps;

- (void)registerPreferenceChangeBlock:(HBPreferencesChangeCallback)callback;

@end
