#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

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
		NSDictionary *userInfo = notification.userInfo;
		NSInteger state = ((NSNumber *)userInfo[@"State"]).integerValue;
		HBTSPlusProvider *whatsAppProvider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"net.whatsapp.WhatsApp"];
		if (state == 1) {
			WAChatStorage *storage = [%c(WASharedAppData) chatStorage];
			WAChatSession *chatSession = [storage newOrExistingChatSessionForJID:userInfo[@"JID"]];
			WAContactInfo *contactInfo = [[%c(WAContactInfo) alloc] initWithChatSession:chatSession];

			[whatsAppProvider showNotificationWithIconName:@"TypeStatusPlusWhatsApp" title:@"Typing:" content:contactInfo.fullName];
		} else if (state == 0) {
			[whatsAppProvider hideNotification];
		}
	}];
}
