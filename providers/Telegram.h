@interface TLUpdate : NSObject

@end

@interface TLUpdate$updateUserTyping : TLUpdate

@property (nonatomic) NSInteger user_id;

@end

@interface TLUpdates$updateShort : NSObject

@property(retain, nonatomic) TLUpdate *update;

@end

@interface TGTelegraphUserInfoController : NSObject

- (instancetype)initWithUid:(NSInteger)uid;

@end

@interface TGUser : NSObject

- (NSString *)displayName;

@end

@interface TLUpdates$updates : TLUpdate

@property (retain, nonatomic) NSArray *chats;

@property (retain, nonatomic) NSArray *users;

@property (retain, nonatomic) NSArray *updates;

@end

@interface TLPeer : NSObject

@end

@interface TLUpdate$updateReadHistoryOutbox : TLUpdate

@property(retain, nonatomic) TLPeer *peer;

@end

@interface TLPeer$peerUser : TLPeer

@property (nonatomic) NSInteger user_id;

@end
