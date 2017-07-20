#import "HBTSPlusProviderController.h"

@interface HBTSPlusProviderController (Private)

- (void)loadProviders;

@property (nonatomic, retain, readonly) NSSet *appsRequiringBackgroundSupport;

@end
