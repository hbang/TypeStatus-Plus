#import "Messenger.h"

typedef void (^HBTSPlusMessengerNameFetcherCompletion)(NSString *displayName);

@interface HBTSPlusMessengerNameFetcher : NSObject <FBMUserFetcherDelegate>

- (void)userDisplayNameForID:(NSString *)userId completion:(HBTSPlusMessengerNameFetcherCompletion)completion;

@end
