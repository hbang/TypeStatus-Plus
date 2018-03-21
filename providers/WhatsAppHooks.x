#import <TypeStatusProvider/TypeStatusProvider.h>
#import "WhatsApp.h"

%hook WAMessageInfo

%property (nonatomic, retain) NSMutableSet *_typeStatusPlus_alreadyNotifiedReceipts;

- (instancetype)init {
	self = %orig;
	
	if (self) {
		self._typeStatusPlus_alreadyNotifiedReceipts = [[NSMutableSet alloc] init];
	}
	
	return self;
}

%end

NSString *nameFromJID(NSString *jid) {
	WAChatStorage *storage = [%c(WASharedAppData) chatStorage];
	WAChatSession *chatSession = [storage newOrExistingChatSessionForJID:jid options:nil];
	WAContact *contact = [[%c(WAContact) alloc] initWithChatSession:chatSession];
	return contact.shortName;
}

%ctor {
	if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"net.whatsapp.WhatsApp"]) {
		return;
	}

	%init;

	HBTSProvider *whatsAppProvider = [[HBTSProviderController sharedInstance] providerForAppIdentifier:@"net.whatsapp.WhatsApp"];

	[[NSNotificationCenter defaultCenter] addObserverForName:ChatStorageDidUpdateChatSession object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		WAChatSession *chatSession = notification.userInfo[@"ChatSession"];
		WAMessage *message = [chatSession lastMessage];
		WAMessageInfo *messageInfo = message.messageInfo;
		NSDictionary *allReadReceipts = messageInfo.allReadReceipts;

		for (NSString *jid in [allReadReceipts allKeys]) {
			// if we haven't already shown a notification for this read receipt, show one
			if (![messageInfo._typeStatusPlus_alreadyNotifiedReceipts containsObject:jid]) {
				[messageInfo._typeStatusPlus_alreadyNotifiedReceipts addObject:jid];
				NSString *name = nameFromJID(jid);

				HBTSNotification *notification = [[HBTSNotification alloc] initWithType:HBTSMessageTypeReadReceipt sender:name iconName:@"TypeStatusPlusWhatsApp"];
				[whatsAppProvider showNotification:notification];
			}
		}
	}];

	// for when someone types a message

	[[NSNotificationCenter defaultCenter] addObserverForName:XMPPConnectionChatStateDidChange object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		NSDictionary *userInfo = notification.userInfo;
		NSInteger state = ((NSNumber *)userInfo[@"State"]).integerValue;

		if (state == 1) {
			NSString *name = nameFromJID(userInfo[@"JID"]);

			HBTSNotification *notification = [[HBTSNotification alloc] initWithType:HBTSMessageTypeTyping sender:name iconName:@"TypeStatusPlusWhatsApp"];
			[whatsAppProvider showNotification:notification];
		} else if (state == 0) {
			[whatsAppProvider hideNotification];
		}
	}];
}
