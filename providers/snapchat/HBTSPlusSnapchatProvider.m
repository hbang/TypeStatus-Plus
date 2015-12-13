#import "HBTSPlusSnapchatProvider.h"

@implementation HBTSPlusSnapchatProvider

- (id)init {
	if (self = [super init]) {
		self.name = @"Snapchat";
		self.preferencesBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlusProvider.bundle/"] retain];
		self.preferencesClass = @"HBTSPlusSnapchatRootListController";
	}
	return self;
}

@end
