#import "../Global.h"
#import <BulletinBoard/BBDataProvider.h>

@interface HBTSPlusBulletinProvider : NSObject <BBDataProvider>

+ (instancetype)sharedInstance;

- (void)showBulletinWithTitle:(NSString *)title content:(NSString *)content;

@end
