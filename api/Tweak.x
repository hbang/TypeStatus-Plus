#import "../api/HBTSPlusProviderController.h"
#import "../api/HBTSPlusProviderController+Private.h"

%hook UIApplication

- (void)_deactivateForReason:(int)reason notify:(BOOL)notify {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		notify = NO;
	}

	%orig;
}

- (BOOL)_isLaunchedSuspended {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		return NO;
	}
	return %orig;
}

- (BOOL)isSuspended {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		return NO;
	}
	return %orig;
}

- (BOOL)isSuspendedUnderLock {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		return NO;
	}
	return %orig;
}

- (BOOL)isSuspendedEventsOnly {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		return NO;
	}
	return %orig;
}

%end