#import <ApplePushService/APSIncomingMessage.h>
#import <TypeStatusPlusProvider/HBTSNotification.h>
#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

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
			HBTSNotification *notification = [[[HBTSNotification alloc] init] autorelease];
			notification.content = message.userInfo[@"local_message"]; // @"Ben Rosen took a screenshot!"
			notification.boldRange = [notification.content rangeOfString:message.userInfo[@"sender"]];
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
