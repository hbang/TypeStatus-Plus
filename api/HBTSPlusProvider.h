NS_ASSUME_NONNULL_BEGIN

@interface HBTSPlusProvider : NSObject

@property (nonatomic, retain) NSString *name, *appIdentifier;

@property (nonatomic, retain, nullable) NSBundle *preferencesBundle;
@property (nonatomic, retain, nullable) NSString *preferencesClass;

+ (void)showNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content;

+ (void)hideNotification;

@end

NS_ASSUME_NONNULL_END
