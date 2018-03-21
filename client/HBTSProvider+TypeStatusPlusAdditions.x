#import "HBTSProvider+TypeStatusPlusAdditions.h"
#import <MobileCoreServices/LSApplicationProxy.h>
#include <objc/runtime.h>

@implementation HBTSProvider (TypeStatusPlusAdditions)

- (NSString *)name {
	NSString *name = objc_getAssociatedObject(self, _cmd);

	if (!name) {
		// try to get the best name we can for this provider. if we can get an LSApplicationProxy, use
		// its name. 
		NSBundle *bundle = [NSBundle bundleForClass:self.class];

		// try and get the best name possible from its bundle
		name = bundle.localizedInfoDictionary[@"CFBundleName"]
			?: bundle.infoDictionary[@"CFBundleName"]
			?: bundle.executableURL.lastPathComponent
			?: bundle.bundleURL.lastPathComponent;

		// if we didn’t get a name, but we have an app identifier, get that app’s name
		if (!name && self.appIdentifier) {
			LSApplicationProxy *app = [LSApplicationProxy applicationProxyForIdentifier:self.appIdentifier];
			name = app.localizedName;
		}

		// fallback in case we couldn’t get anything
		if (!name) {
			name = @"Unknown";
		}

		objc_setAssociatedObject(self, _cmd, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	return name;
}

@end
