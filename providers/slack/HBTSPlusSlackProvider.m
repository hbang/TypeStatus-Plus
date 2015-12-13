#import "HBTSPlusSlackProvider.h"

@implementation HBTSPlusSlackProvider

- (id)init {
	if (self = [super init]) {
		self.name = @"Slack";
		self.preferencesBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlusSlackPrefs.bundle/"] retain];
		self.preferencesClass = @"HBTSPlusSlackRootListController";
	}
	return self;
}

@end