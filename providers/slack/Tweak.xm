#import <TypeStatusPlusProvider/HBTSPlusProvider.h>

#define SLKUserTyping @"SLKUserTyping"

%ctor {
	[[NSNotificationCenter defaultCenter] addObserverForName:SLKUserTyping object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		NSDictionary *userInfo = notification.userInfo;
		HBLogDebug(@"The user info is %@", userInfo);
	}];
}