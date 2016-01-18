#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

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

%hook TGTLSerialization

- (id)parseMessage:(NSData *)message {
	TLUpdates$updateShort *updateShort = %orig;

	if (![updateShort isKindOfClass:%c(TLUpdates$updateShort)]) {
		return updateShort;
	}

	if (![updateShort.update isKindOfClass:%c(TLUpdate$updateUserTyping)] && ![updateShort.update isKindOfClass:%c(TLUpdate$updateChatUserTyping)]) {
		return updateShort;
	}

	TLUpdate$updateUserTyping *userTypingUpdate = (TLUpdate$updateUserTyping *)updateShort.update;
	NSInteger userId = userTypingUpdate.user_id;

	TGTelegraphUserInfoController *userController = [[%c(TGTelegraphUserInfoController) alloc] initWithUid:userId];
	TGUser *user = [userController valueForKey:@"_user"];
	NSString *userDisplayName = [user displayName];

		[[[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"ph.telegra.Telegraph"] showNotificationWithIconName:@"TypeStatusPlusTelegram" title:@"Typing:" content:userDisplayName];

	return updateShort;
}

%end
