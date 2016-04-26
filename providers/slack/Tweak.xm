#import <TypeStatusPlusProvider/HBTSNotification.h>
#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

#define SLKUserTyping @"SLKUserTyping"
#define kSLKUserKey @"user"
#define kSLKChannelKey @"channel"

@interface SLKUser : NSObject
// TODO: make this an enum
+ (instancetype)userForId:(NSString *)identifier contextType:(unsigned long long)contextType;

- (NSString *)displayName;

@end

@interface SLKChannel
// TODO: make this an enum
+ (instancetype)channelForId:(NSString *)identifier contextType:(unsigned long long)contextType;

- (NSString *)displayTitle;

@end

%ctor {
	NSBundle *bundle = [[NSBundle bundleWithPath:@"/Library/TypeStatus/Providers/Slack.bundle"] retain];

	[[NSNotificationCenter defaultCenter] addObserverForName:SLKUserTyping object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

		NSString *rawUserId = notification.userInfo[kSLKUserKey];
		NSString *rawChannelId = notification.userInfo[kSLKChannelKey];

		SLKUser *user = [%c(SLKUser) userForId:rawUserId contextType:1];
		SLKChannel *channel = [%c(SLKChannel) channelForId:rawChannelId contextType:1];

		// Typing: Ben Rosen in #general

		HBTSPlusProvider *slackProvider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"com.tinyspeck.chatlyio"];

		NSString *sender = user.displayName;

		if (channel) {
			sender = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"SENDER_IN_CHANNEL", @"Localizable", bundle, @"String used in the status bar for messages sent in a channel. “Typing: kirb in #general”"), user.displayName, channel.displayTitle];
		}

		HBTSNotification *tsNotification = [[[HBTSNotification alloc] initWithType:HBTSNotificationTypeTyping sender:sender iconName:@"TypeStatusPlusSlack"] autorelease];
		[slackProvider showNotification:tsNotification];
	}];
}
