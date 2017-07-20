#import "../api/HBTSPlusProviderController.h"
#import "../api/HBTSPlusProviderController+Private.h"

HBTSPlusProviderController *controller;

%hook UIApplication

- (void)_deactivateForReason:(NSInteger)reason notify:(BOOL)notify {
	if ([controller applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		notify = NO;
	}

	%orig;
}

- (BOOL)_isLaunchedSuspended {
	return [controller applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier] ? NO : %orig;
}

- (BOOL)isSuspended {
	return [controller applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier] ? NO : %orig;
}

- (BOOL)isSuspendedUnderLock {
	return [controller applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier] ? NO : %orig;
}

- (BOOL)isSuspendedEventsOnly {
	return [controller applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier] ? NO : %orig;
}

%end

%ctor {
	controller = [HBTSPlusProviderController sharedInstance];
}
