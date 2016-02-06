#import "../Global.h"
#import <BulletinBoard/BBDataProvider.h>

@interface HBTSPlusBulletinProvider : NSObject <BBDataProvider>

+ (instancetype)sharedInstance;

- (void)showBulletinWithContent:(NSString *)content appIdentifier:(NSString *)appIdentifier;

@end
