@interface HBTSPlusPreferences : NSObject

@property (nonatomic, readonly) BOOL enabled;

@property (nonatomic, readonly) BOOL showNotificationsEverywhere;

+ (instancetype)sharedInstance;

- (NSString *)applicationUsingUnreadCount;

- (BOOL)providerIsEnabled:(NSString *)appIdentifier;

@end
