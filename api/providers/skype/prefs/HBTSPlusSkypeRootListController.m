#include "HBTSPlusSkypeRootListController.h"

@implementation HBTSPlusSkypeRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

@end
