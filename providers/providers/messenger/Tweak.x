#import "HBTSPlusMessengerNameFetcher.h"
#import "Messenger.h"
#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

%hook FBMSPReadReceiptDeltaHandler

- (void)_processDeltaReadReceipt:(MNMessagesSyncDeltaReadReceipt *)readReceipt completion:(id)completionBlock {
	%orig;

	// get the user id. in a one-on-one chat it's otherUserFbId; in a group chat it's actorFbId
	MNMessagesSyncThreadKey *threadKey = readReceipt.threadKey;
	long long userId = threadKey.otherUserFbId ?: readReceipt.actorFbId;
	NSString *userIdString = [NSString stringWithFormat:@"%llu", userId];

	// fetch the name and send our notification off
	HBTSPlusMessengerNameFetcher *fetcher = [[HBTSPlusMessengerNameFetcher alloc] init];
	[fetcher userDisplayNameForID:userIdString completion:^(NSString *displayName) {
		HBTSPlusProvider *messengerProvider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"com.facebook.Messenger"];

		HBTSNotification *notification = [[HBTSNotification alloc] initWithType:HBTSMessageTypeReadReceipt sender:displayName iconName:@"TypeStatusPlusMessenger"];
		[messengerProvider showNotification:notification];
	}];
}

%end

%ctor {
	if (![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.facebook.Messenger"]) {
		return;
	}

	%init;

	// set up our listener for typing NSNotifications
	[[NSNotificationCenter defaultCenter] addObserverForName:OrcaAppReceivedTyping object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		NSDictionary *userInfo = notification.userInfo;
		NSString *senderID = userInfo[kMessengerSenderFBIDKey];
		BOOL state = [userInfo[kMessengerStateKey] boolValue];

		HBTSPlusProvider *messengerProvider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"com.facebook.Messenger"];

		// if this is a typing started message, show a notification. otherwise, hide it
		if (state) {
			HBTSPlusMessengerNameFetcher *fetcher = [[HBTSPlusMessengerNameFetcher alloc] init];
			[fetcher userDisplayNameForID:senderID completion:^(NSString *displayName) {
				HBTSNotification *notification = [[HBTSNotification alloc] initWithType:HBTSMessageTypeTyping sender:displayName iconName:@"TypeStatusPlusMessenger"];
				[messengerProvider showNotification:notification];
			}];
		} else {
			[messengerProvider hideNotification];
		}
	}];
}
