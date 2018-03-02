#import <BulletinBoard/BBDataProvider.h>

@class HBTSNotification;

@interface HBTSPlusBulletinProvider : BBDataProvider <BBDataProvider>

+ (instancetype)sharedInstance;

- (void)showBulletinForNotification:(HBTSNotification *)notification;

- (void)clearBulletinsIfNeeded;
- (void)clearBulletinsForBundleIdentifier:(NSString *)bundleIdentifier;

@property (nonatomic, readonly) BOOL showsWhenUnlocked;
@property (nonatomic, readonly) BOOL showsInLockScreen;

@end
