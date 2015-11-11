NS_ASSUME_NONNULL_BEGIN

@interface HBTSPlusProvider : NSObject

@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain, nullable) NSBundle *preferencesBundle;

@property (nonatomic, retain, nullable) NSString *preferencesClass;

@property (nonatomic, retain) UIColor *preferencesColor;

- (void)showNotification:(NSString *)text;

@end

NS_ASSUME_NONNULL_END