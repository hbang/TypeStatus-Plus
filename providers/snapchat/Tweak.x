#import <ApplePushService/APSIncomingMessage.h>
#import <TypeStatusPlusProvider/HBTSNotification.h>
#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

NSBundle *bundle;

%hook UNRemoteNotificationServer

- (void)connection:(id)connection didReceiveIncomingMessage:(APSIncomingMessage *)message {
	if ([message.topic isEqualToString:@"com.toyopagroup.picaboo"]) {
		NSString *type = message.userInfo[@"type"];

		if ([type isEqualToString:@"typing"]) {
			// typing
			HBTSNotification *notification = [[[HBTSNotification alloc] initWithType:HBTSMessageTypeTyping sender:message.userInfo[@"sender"] iconName:@"TypeStatusPlusSnapchat"] autorelease];

			HBTSPlusProvider *provider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"com.toyopagroup.picaboo"];
			[provider showNotification:notification];
		} else if ([type isEqualToString:@"screenshot"] || [type isEqualToString:@"chat_screenshot"]) {
			// snap screenshot (ss) or chat screenshot (cs)
			NSString *sender = message.userInfo[@"sender"];

			HBTSNotification *notification = [[[HBTSNotification alloc] init] autorelease];
			notification.content = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"SENDER_TOOK_A_SCREENSHOT", @"Localizable", bundle, @"String used in the status bar for screenshot notifications. “kirb took a screenshot!”"), sender];
			notification.boldRange = [notification.content rangeOfString:sender];
			notification.statusBarIconName = @"TypeStatusPlusSnapchat";

			HBTSPlusProvider *provider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"com.toyopagroup.picaboo"];
			[provider showNotification:notification];
		} else {
			%orig;
		}
	} else {
		%orig;
	}
}

%end

%ctor {
	bundle = [[NSBundle bundleWithPath:@"/Library/TypeStatus/Providers/Snapchat.bundle"] retain];

	if (IN_SPRINGBOARD) {
		// UNRemoteNotificationServer in iOS 9, UNSRemoteNotificationServer in iOS 10
		Class serverClass = %c(UNSRemoteNotificationServer) ?: %c(UNRemoteNotificationServer);
		%init(_ungrouped, UNRemoteNotificationServer = serverClass);
	}
}
