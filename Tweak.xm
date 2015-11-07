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

%hook BBDataProvider

- (id)defaultSubsectionInfos {
	return %orig;
}

%end

#pragma mark - Constructor

%ctor {
	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSClientSetStatusBarNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		HBTSStatusBarType type = (HBTSStatusBarType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue;
		NSString *sender = notification.userInfo[kHBTSMessageSenderKey];
		[[HBTSBulletinProvider sharedInstance] showBulletinOfType:type contactName:sender];
	}];
}
