@interface HBTSPlusProviderBackgroundingManager : NSObject

+ (void)putAppWithIdentifier:(NSString *)appIdentifier intoBackground:(BOOL)backgrounded;

@end
