#import "HBTSPlusWhatsappProvider.h"

@implementation HBTSPlusWhatsappProvider

- (id)init {
	if (self = [super init]) {
		self.name = @"Whatsapp";
		self.preferencesBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlusWhatsappPrefs.bundle/"] retain];
		self.preferencesClass = @"HBTSPlusWhatsappRootListController";
	}
	return self;
}

@end