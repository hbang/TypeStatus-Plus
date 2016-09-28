@interface HBTSPlusClient : NSObject

+ (instancetype)sharedInstance;

- (NSInteger)badgeCount;
- (BOOL)showBanners;

- (void)statusBarTapped;

@end
