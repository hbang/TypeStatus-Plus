#import <ApplePushService/APSIncomingMessage.h>
#import <TypeStatusProvider/TypeStatusProvider.h>

NSBundle *bundle;

@interface UNSNotificationRecord : NSObject

@property (nonatomic, copy) NSDictionary *userInfo;

@end

%hook UNSNotificationRepository

- (void)saveNotificationRecord:(UNSNotificationRecord *)record forBundleIdentifier:(NSString *)bundleIdentifier withCompletionHandler:(id)completion {
	if ([bundleIdentifier isEqualToString:@"com.toyopagroup.picaboo"]) {
		NSString *type = record.userInfo[@"type"];

		if ([type isEqualToString:@"typing"]) {
			// typing
			HBTSNotification *notification = [[HBTSNotification alloc] initWithType:HBTSMessageTypeTyping sender:record.userInfo[@"sender"] iconName:@"TypeStatusPlusSnapchat"];

			HBTSProvider *provider = [[HBTSProviderController sharedInstance] providerForAppIdentifier:@"com.toyopagroup.picaboo"];
			[provider showNotification:notification];
		} else if ([type isEqualToString:@"screenshot"] || [type isEqualToString:@"chat_screenshot"]) {
			// snap screenshot (ss) or chat screenshot (cs)
			NSString *sender = record.userInfo[@"sender"];

			// TODO: why are we using our own string for something that's already provided to us?!
			HBTSNotification *notification = [[HBTSNotification alloc] init];
			notification.content = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"SENDER_TOOK_A_SCREENSHOT", @"Localizable", bundle, @""), sender];
			notification.boldRange = [notification.content rangeOfString:sender];
			notification.statusBarIconName = @"TypeStatusPlusSnapchat";

			HBTSProvider *provider = [[HBTSProviderController sharedInstance] providerForAppIdentifier:@"com.toyopagroup.picaboo"];
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
	bundle = [NSBundle bundleWithPath:@"/Library/TypeStatus/Providers/Snapchat.bundle"];

	if (IN_SPRINGBOARD) {
		%init;
	}
}
