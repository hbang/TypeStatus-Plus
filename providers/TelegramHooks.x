#import <TypeStatusProvider/TypeStatusProvider.h>
#import "Telegram.h"

%hook TGTLSerialization

- (id)parseMessage:(NSData *)message {
	id original = %orig;

	HBTSProvider *telegramProvider = [[HBTSProviderController sharedInstance] providerForAppIdentifier:@"ph.telegra.Telegraph"];

	if ([original isKindOfClass:%c(TLUpdates$updateShort)]) {
		TLUpdates$updateShort *updateShort = (TLUpdates$updateShort *)original;
		if (![updateShort.update isKindOfClass:%c(TLUpdate$updateUserTyping)] && ![updateShort.update isKindOfClass:%c(TLUpdate$updateChatUserTyping)]) {
			return updateShort;
		}

		TLUpdate$updateUserTyping *userTypingUpdate = (TLUpdate$updateUserTyping *)updateShort.update;
		NSInteger userId = userTypingUpdate.user_id;

		TGTelegraphUserInfoController *userController = [[%c(TGTelegraphUserInfoController) alloc] initWithUid:userId];
		TGUser *user = [userController valueForKey:@"_user"];
		NSString *userDisplayName = [user displayName];

		HBTSNotification *notification = [[HBTSNotification alloc] initWithType:HBTSMessageTypeTyping sender:userDisplayName iconName:@"TypeStatusPlusTelegram"];
		[telegramProvider showNotification:notification];
	} else if ([original isKindOfClass:%c(TLUpdates$updates)]) {
		TLUpdates$updates *update = (TLUpdates$updates *)original;
		for (TLUpdate *regularUpdate in update.updates) {
			if ([regularUpdate isKindOfClass:%c(TLUpdate$updateReadHistoryOutbox)]) {
				TLUpdate$updateReadHistoryOutbox *readUpdate = (TLUpdate$updateReadHistoryOutbox *)regularUpdate;

				TLPeer$peerUser *peer = (TLPeer$peerUser *)readUpdate.peer;
				if (![peer isKindOfClass:%c(TLPeer$peerUser)]) {
					break;
				}

				NSInteger userId = peer.user_id;

				TGTelegraphUserInfoController *userController = [[%c(TGTelegraphUserInfoController) alloc] initWithUid:userId];
				TGUser *user = [userController valueForKey:@"_user"];
				NSString *userDisplayName = [user displayName];

				HBTSNotification *notification = [[HBTSNotification alloc] initWithType:HBTSMessageTypeReadReceipt sender:userDisplayName iconName:@"TypeStatusPlusTelegram"];
				[telegramProvider showNotification:notification];
			}
		}
	}

	return original;
}

%end

%ctor {
	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"ph.telegra.Telegraph"]) {
		%init;
	}
}
