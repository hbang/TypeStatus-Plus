@class CKConversation;

@interface HBTSPlusMessagesTypingManager : NSObject

+ (instancetype)sharedInstance;

- (void)addConversation:(CKConversation *)conversation;

- (void)removeConversation:(CKConversation *)conversation;

- (BOOL)conversationIsTyping:(CKConversation *)conversation;

- (NSString *)nameForHandle:(NSString *)handle;

@end
