@interface HBTSPlusPreferences : NSObject

@property (nonatomic, readonly) BOOL enabled;

@property (nonatomic, readonly) BOOL showWhenInForeground;

@property (nonatomic, readonly) BOOL useTSPIcon;

@property (nonatomic, readonly) BOOL showBannersOnLockScreen, showBannersOnHomeScreen, showBannersInApps;

@property (nonatomic, readonly) BOOL vibrateOnLockScreen, vibrateOnHomeScreen, vibrateInApps;

+ (instancetype)sharedInstance;

- (NSString *)applicationUsingUnreadCount;

- (BOOL)providerIsEnabled:(NSString *)appIdentifier;

@end
