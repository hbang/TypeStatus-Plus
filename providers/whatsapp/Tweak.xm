#import <TypeStatusPlusProvider/HBTSPlusProvider.h>

#define XMPPConnectionChatStateDidChange @"XMPPConnectionChatStateDidChange"

%ctor {
	[[NSNotificationCenter defaultCenter] addObserverForName:XMPPConnectionChatStateDidChange object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		NSDictionary *userInfo = notification.userInfo;
		NSInteger state = ((NSNumber *)userInfo[@"State"]).integerValue;
		if (state == 1) {
			[HBTSPlusProvider showNotificationWithIconName:@"WhatsAppIcon" title:@"Typing:" content:userInfo[@"JID"]];
		} else if (state == 0) {
			[HBTSPlusProvider hideNotification];
		}
		HBLogDebug(@"userInfo = %@, state is %li", userInfo, (long)state);
	}];
}
