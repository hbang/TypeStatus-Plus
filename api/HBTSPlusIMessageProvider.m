#import "HBTSPlusIMessageProvider.h"

@implementation HBTSPlusIMessageProvider

- (instancetype)init {
	self = [super init];

	if (self) {
		self.name = @"iMessage";
		self.appIdentifier = @"com.apple.MobileSMS";
		self.preferencesBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"];
		self.preferencesClass = @"HBTSAlertsListController";
	}

	return self;
}

@end
