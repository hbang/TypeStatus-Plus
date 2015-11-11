#include "HBTSPlusTelegramRootListController.h"

@implementation HBTSPlusTelegramRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

@end
