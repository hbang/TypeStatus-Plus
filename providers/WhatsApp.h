#define XMPPConnectionChatStateDidChange @"XMPPConnectionChatStateDidChange"
#define ChatStorageDidUpdateChatSession @"ChatStorageDidUpdateChatSession"

@interface WAMessageInfo : NSObject

@property (nonatomic, retain) NSMutableSet *_typeStatusPlus_alreadyNotifiedReceipts;

@property (nonatomic, copy, readonly) NSDictionary *allReadReceipts;

@end

@interface WAMessage : NSObject

@property (nonatomic, retain) WAMessageInfo *messageInfo;

@end

@interface WAChatSession : NSObject

@property (nonatomic, retain) WAMessage *lastMessage;

@end

@interface WAChatStorage : NSObject

- (WAChatSession *)newOrExistingChatSessionForJID:(NSString *)jid options:(id)options;

@end

@interface WASharedAppData : NSObject

+ (WAChatStorage *)chatStorage;

@end

@interface WAContact : NSObject

- (instancetype)initWithChatSession:(WAChatSession *)chatSession;

- (NSString *)shortName;

@end
