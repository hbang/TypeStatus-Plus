#import "HBTSPlusMessengerNameFetcher.h"
#import "Messenger.h"
#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

%hook FBMSPReadReceiptDeltaHandler

- (void)_processDeltaReadReceipt:(MNMessagesSyncDeltaReadReceipt *)readReceipt completion:(id)completionBlock {
	%orig;

	MNMessagesSyncThreadKey *threadKey = readReceipt.threadKey;
	long long userId = threadKey.otherUserFbId ?: readReceipt.actorFbId;
	NSString *userIdString = [NSString stringWithFormat:@"%llu", userId];

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
