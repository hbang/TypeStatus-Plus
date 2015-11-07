#import "HBTSBulletinProvider.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <BulletinBoard/BBLocalDataProviderStore.h>

%hook SBApplication

- (void)setApplicationState:(unsigned)state {
	%orig;
}

%end

#pragma mark - Notification Center

%hook BBLocalDataProviderStore

- (void)loadAllDataProvidersAndPerformMigration:(BOOL)arg1 {
	%orig;
	[self addDataProvider:[HBTSBulletinProvider sharedInstance] performMigration:YES];
}

%end

#pragma mark - Constructor

%ctor {
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSClientSetStatusBarNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		HBTSStatusBarType type = (HBTSStatusBarType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue;
		NSString *sender = notification.userInfo[kHBTSMessageSenderKey];
		[[HBTSBulletinProvider sharedInstance] showBulletinOfType:type contactName:sender];
	}];

	NSString *providerPath = @"/Library/TypeStatus/Providers";
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:providerPath];
	 
	NSString *file;
	while ((file = [dirEnum nextObject])) {
	    if ([[file pathExtension] isEqualToString: @"bundle"]) {
	    	[[NSBundle bundleWithPath:[providerPath stringByAppendingPathComponent:file]] retain];
	    }
	}
}
