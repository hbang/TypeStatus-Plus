#import <SpringBoard/SBApplication.h>
#import <FrontBoard/FBProcess.h>
#import <SpringBoard/SpringBoard.h>
#import <AssertionServices/BKSProcessAssertion.h>
#import <FrontBoard/FBProcessManager.h>
#import "../HBTSPlusPreferences.h"
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

/* [[HBTSPlusProviderController sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]*/

@interface FBApplicationProcess : NSObject

@property (nonatomic, retain) NSString *bundleIdentifier;

@end

%hook FBApplicationProcess

- (BOOL)isPendingExit {
	return %orig;//return ![[%c(HBTSPlusProviderController) sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier];
}

- (void)_queue_watchdogTerminateWithReason:(int)arg1 format:(id)arg2 {
	if ([[%c(HBTSPlusProviderController) sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		return;
	}
	%orig;
}

- (void)killForReason:(int)arg1 andReport:(BOOL)arg2 withDescription:(id)arg3 {
	if ([[%c(HBTSPlusProviderController) sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		return;
	}
	%orig;
}

- (void)killForReason:(int)arg1 andReport:(BOOL)arg2 withDescription:(id)arg3 completion:(id /* block */)arg4 {
	if ([[%c(HBTSPlusProviderController) sharedInstance] applicationWithIdentifierRequiresBackgrounding:self.bundleIdentifier]) {
		return;
	}
	%orig;
}

%end

%hook FBProcessWatchdog

- (void)_watchdogTimerFired {
	if ([[%c(HBTSPlusProviderController) sharedInstance] applicationWithIdentifierRequiresBackgrounding:[self valueForKey:@"_processBundleID"]]) {
		return;
	}
	%orig;
}

- (id)initWithProcess:(id)arg1 event:(int)arg2 timeout:(double)arg3 completion:(id /* block */)arg4 {
	if ([[%c(HBTSPlusProviderController) sharedInstance] applicationWithIdentifierRequiresBackgrounding:[self valueForKey:@"_processBundleID"]]) {
		return nil;
	}
	return %orig;
}

- (id)initWithTimeout:(double)arg1 queue:(id)arg2 completion:(id /* block */)arg3 {
	if ([[%c(HBTSPlusProviderController) sharedInstance] applicationWithIdentifierRequiresBackgrounding:[self valueForKey:@"_processBundleID"]]) {
		return nil;
	}
	return %orig;
}

%end

%hook FBUIApplicationService

- (void)handleSuspendApplicationProcess:(id)arg1 {
	if ([[%c(HBTSPlusProviderController) sharedInstance] applicationWithIdentifierRequiresBackgrounding:[self valueForKey:@"_processBundleID"]]) {
		return;
	}
	%orig;
}

%end

%hook FBSystemAppProxyServiceServer

- (void)_handleSuspendApplication:(id)arg1 forClient:(id)arg2 {
	if ([[%c(HBTSPlusProviderController) sharedInstance] applicationWithIdentifierRequiresBackgrounding:[self valueForKey:@"_processBundleID"]]) {
		return;
	}
	%orig;
}

%end
