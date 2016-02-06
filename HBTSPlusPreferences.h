@interface HBTSPlusPreferences : NSObject

@property (nonatomic, readonly) BOOL enabled;

@property (nonatomic, readonly) BOOL showWhenInForeground;

@property (nonatomic, readonly) BOOL useAppIcon;

@property (nonatomic, readonly) BOOL showBannersOnLockScreen, showBannersOnHomeScreen, showBannersInApps;

@property (nonatomic, readonly) BOOL vibrateOnLockScreen, vibrateOnHomeScreen, vibrateInApps;

@property (nonatomic, readonly) NSString *applicationUsingUnreadCount;

+ (instancetype)sharedInstance;

- (BOOL)providerIsEnabled:(NSString *)appIdentifier;

@end
