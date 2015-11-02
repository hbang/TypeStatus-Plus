#import "HBTSBulletinProvider.h"
#import <Foundation/NSDistributedNotificationCenter.h>

%hook SBApplication

- (void)setApplicationState:(unsigned)state {
	%orig;
}

%end

#pragma mark - Notification Center

%hook BBDataProviderManager

- (void)loadAllDataProviders {
	%orig;
	[self _addDataProvider:[HBTSBulletinProvider sharedInstance] sortSectionsNow:YES];
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
