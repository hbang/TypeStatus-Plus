#import <TypeStatusPlusProvider/HBTSPlusProvider.h>

#define XMPPConnectionChatStateDidChange @"XMPPConnectionChatStateDidChange"

@interface WAChatSession

@end

@interface WAChatStorage

- (WAChatSession *)newOrExistingChatSessionForJID:(NSString *)jid;

@end

@interface WASharedAppData

+ (WAChatStorage *)chatStorage;

@end

@interface WAContactInfo

- (instancetype)initWithChatSession:(WAChatSession *)chatSession;

- (NSString *)fullName;

@end

%ctor {
	[[NSNotificationCenter defaultCenter] addObserverForName:XMPPConnectionChatStateDidChange object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		HBLogDebug(@"the user info is %@", notification.userInfo);
		NSDictionary *userInfo = notification.userInfo;
		NSInteger state = ((NSNumber *)userInfo[@"State"]).integerValue;
		if (state == 1) {
			WAChatStorage *storage = [%c(WASharedAppData) chatStorage];
			WAChatSession *chatSession = [storage newOrExistingChatSessionForJID:userInfo[@"JID"]];
			WAContactInfo *contactInfo = [[%c(WAContactInfo) alloc] initWithChatSession:chatSession];
			NSString *fullName = contactInfo.fullName;

			[HBTSPlusProvider showNotificationWithIconName:@"WhatsAppIcon" title:@"WhatsApp:" content:fullName];
		} else if (state == 0) {
			[HBTSPlusProvider hideNotification];
		}
		HBLogDebug(@"userInfo = %@, state is %li", userInfo, (long)state);
	}];
}
