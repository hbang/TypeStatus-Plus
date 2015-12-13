#import "HBTSPlusSlackProvider.h"

@implementation HBTSPlusSlackProvider

- (id)init {
	if (self = [super init]) {
		self.name = @"Slack";
		self.preferencesBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlusProvider.bundle/"] retain];
		self.preferencesClass = @"HBTSPlusSlackRootListController";
	}
	return self;
}

@end
