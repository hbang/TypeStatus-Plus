NS_ASSUME_NONNULL_BEGIN

@interface HBTSPlusProvider : NSObject

@property (nonatomic, retain) NSString *name;

@property (nonatomic, retain, nullable) NSBundle *preferencesBundle;

@property (nonatomic, retain, nullable) NSString *preferencesClass;

- (void)showNotification:(NSString *)text;

@end

NS_ASSUME_NONNULL_END