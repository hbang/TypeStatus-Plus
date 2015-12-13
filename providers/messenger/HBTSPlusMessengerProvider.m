#import "HBTSPlusMessengerProvider.h"

@implementation HBTSPlusMessengerProvider

- (id)init {
	if (self = [super init]) {
		self.name = @"Messenger";
		self.preferencesBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlusProvider.bundle/"] retain];
		self.preferencesClass = @"HBTSPlusMessengerRootListController";
	}
	return self;
}

@end
