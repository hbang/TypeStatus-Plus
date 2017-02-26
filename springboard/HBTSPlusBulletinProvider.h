#import <BulletinBoard/BBDataProvider.h>

@class HBTSNotification;

@interface HBTSPlusBulletinProvider : BBDataProvider <BBDataProvider>

+ (instancetype)sharedInstance;

- (void)showBulletinForNotification:(HBTSNotification *)notification;
- (void)clearAllBulletins;

@end
