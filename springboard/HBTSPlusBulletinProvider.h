#import <BulletinBoard/BBDataProvider.h>

@class HBTSNotification;

@interface HBTSPlusBulletinProvider : NSObject <BBDataProvider>

+ (instancetype)sharedInstance;

- (void)showBulletinForNotification:(HBTSNotification *)notification;
- (void)clearAllBulletins;

@end
