#import "HBTSPlusProviderBackgroundingManager.h"
#import "HBTSPlusProviderController.h"
#import <SpringBoard/SBApplication.h>

%group SpringBoard
%hook SBApplication

- (BOOL)supportsContinuousBackgroundMode {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		HBLogDebug(@"*** whoa %@ is registering for multitasking", self.bundleIdentifier);
		return YES;
	} else {
		return %orig;
	}
}

- (void)_transientSuspendForTimerFired:(NSTimer *)timer {
	%log;
	if (![[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		%orig;
	}
}

- (void)_suspendForPeriodicWakeTimerFired:(NSTimer *)timer {
	%log;
	if (![[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		%orig;
	}
}

- (void)_didSuspend {
	%log;
	%orig;
}

- (BOOL)shouldLaunchSuspendedAlways {
	BOOL r = %orig;
	%log((BOOL)r);
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		return YES;
	}
	return r;
}

%end
%end

%hook UIApplication

- (void)_setSuspended:(BOOL)suspended {
	if ([[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:[NSBundle mainBundle].bundleIdentifier]) {
		%orig(NO);
	} else {
		%orig;
	}
}

%end

%ctor {
	[[HBTSPlusProviderController sharedInstance] loadProviders];

	%init;

	if (IN_SPRINGBOARD) {
		%init(SpringBoard);
	}
}
