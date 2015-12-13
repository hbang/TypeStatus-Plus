#import "HBTSPlusWhatsAppProvider.h"

@implementation HBTSPlusWhatsAppProvider

- (id)init {
	if (self = [super init]) {
		self.name = @"WhatsApp";
		self.preferencesBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlusProvider.bundle/"] retain];
		self.preferencesClass = @"HBTSPlusWhatsAppRootListController";
	}
	return self;
}

@end
