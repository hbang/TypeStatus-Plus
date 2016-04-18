#import "HBTSPlusProviderController.h"

@interface HBTSPlusProviderController (Private)

- (void)loadProviders;

@property (nonatomic, retain, readonly) NSMutableArray *appsRequiringBackgroundSupport;

@end
