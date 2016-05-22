#import <BulletinBoard/BBDataProvider.h>

@class HBTSNotification;

@interface HBTSPlusBulletinProvider : NSObject <BBDataProvider>

+ (instancetype)sharedInstance;

- (void)showMessagesBulletinWithContent:(NSString *)content;
- (void)showBulletinForNotification:(HBTSNotification *)notification;

- (void)clearAllBulletins;

@end
