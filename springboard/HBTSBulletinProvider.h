#import "Global.h"
#import <BulletinBoard/BBDataProvider.h>

@interface HBTSBulletinProvider : NSObject <BBDataProvider>

+ (instancetype)sharedInstance;

- (void)showBulletinOfType:(HBTSStatusBarType)type contactName:(NSString *)contactName;

@end
