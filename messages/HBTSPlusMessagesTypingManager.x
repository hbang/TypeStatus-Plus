#import "HBTSPlusMessagesTypingManager.h"
#import <ChatKit/CKConversation.h>
#import <ChatKit/CKEntity.h>
#import <IMCore/IMHandle.h>

@implementation HBTSPlusMessagesTypingManager {
	NSMutableSet *_conversations;
}

+ (instancetype)sharedInstance {
	static HBTSPlusMessagesTypingManager *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		_conversations = [[NSMutableSet alloc] init];
	}
	return self;
}

- (void)addConversation:(CKConversation *)conversation {
	[_conversations addObject:conversation];
}

- (void)removeConversation:(CKConversation *)conversation {
	[_conversations removeObject:conversation];
}

- (BOOL)conversationIsTyping:(CKConversation *)conversation {
	for (CKConversation *comparedConversation in _conversations) {
		if ([comparedConversation.name isEqualToString:conversation.name]) {
			return YES;
		}
	}
	return NO;
}

- (NSString *)nameForHandle:(NSString *)handle {
	CKEntity *entity = [CKEntity copyEntityForAddressString:handle];

	if (!entity || !entity.handle.person) {
		return handle;
	}

	return entity.name;
}

@end
