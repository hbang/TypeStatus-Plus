#import <ApplePushService/APSIncomingMessage.h>
#import <TypeStatusPlusProvider/HBTSNotification.h>
#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

NSBundle *bundle;

%hook UNRemoteNotificationServer

- (void)connection:(id)connection didReceiveIncomingMessage:(APSIncomingMessage *)message {
	if ([message.topic isEqualToString:@"com.toyopagroup.picaboo"]) {
		NSString *type = message.userInfo[@"t"];

		if ([type isEqualToString:@"t"]) {
			// typing
			HBTSNotification *notification = [[[HBTSNotification alloc] initWithType:HBTSNotificationTypeTyping sender:message.userInfo[@"sender"] iconName:@"TypeStatusPlusSnapchat"] autorelease];

			HBTSPlusProvider *provider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"com.toyopagroup.picaboo"];
			[provider showNotification:notification];
		} else if ([type isEqualToString:@"ss"] || [type isEqualToString:@"cs"]) {
			// snap screenshot (ss) or chat screenshot (cs)
			NSString *sender = message.userInfo[@"sender"];

			HBTSNotification *notification = [[[HBTSNotification alloc] init] autorelease];
			notification.content = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"SENDER_TOOK_A_SCREENSHOT", @"Localizable", bundle, @"String used in the status bar for screenshot notifications. “kirb took a screenshot!”"), sender];
			notification.boldRange = [notification.content rangeOfString:];
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
}
