#import "HBTSPlusSkypeProvider.h"

@implementation HBTSPlusSkypeProvider

- (id)init {
	if (self = [super init]) {
		self.name = @"Skype";
		self.preferencesBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlusSkypePrefs.bundle/"] retain];
		self.preferencesClass = @"HBTSPlusSkypeRootListController";
	}
	return self;
}

@end