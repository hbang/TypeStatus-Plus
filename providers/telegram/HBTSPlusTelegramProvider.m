#import "HBTSPlusTelegramProvider.h"

@implementation HBTSPlusTelegramProvider

- (id)init {
	if (self = [super init]) {
		self.name = @"Telegram";
		self.preferencesBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlusTelegramPrefs.bundle/"] retain];
		self.preferencesClass = @"HBTSPlusTelegramRootListController";
	}
	return self;
}

@end