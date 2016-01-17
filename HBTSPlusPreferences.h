@interface HBTSPlusPreferences : NSObject

@property (nonatomic, readonly) BOOL enabled;

@property (nonatomic, readonly) BOOL showNotificationsEverywhere;

@property (nonatomic, readonly) BOOL hapticFeedback;

@property (nonatomic, readonly) BOOL showWhenInForeground;

+ (instancetype)sharedInstance;

- (NSString *)applicationUsingUnreadCount;

- (BOOL)providerIsEnabled:(NSString *)appIdentifier;

@end
