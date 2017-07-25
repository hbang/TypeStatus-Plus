#import "HBTSPlusProviderController.h"

typedef void (^HBTSPlusLoadProvidersCompletion)();

@interface HBTSPlusProviderController (Private)

- (void)_loadProvidersWithCompletion:(HBTSPlusLoadProvidersCompletion)completion;

@property (nonatomic, retain, readonly) NSSet *appsRequiringBackgroundSupport;

@end
