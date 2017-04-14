@interface HBTSPlusClient : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSInteger badgeCount;

- (BOOL)showBanners;

- (void)statusBarTapped;

@end
