#import "HBTSPlusMessengerProvider.h"

@implementation HBTSPlusMessengerProvider

- (id)init {
	if (self = [super init]) {
		self.name = @"Messenger";
		self.preferencesBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlusMessengerPrefs.bundle/"] retain];
		self.preferencesClass = @"HBTSPlusMessengerRootListController";
		HBLogDebug(@"The preference bundle is %@, preference class is %@", self.preferencesBundle, self.preferencesClass);

	}
	return self;
}

@end