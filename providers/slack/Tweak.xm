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
	[[NSNotificationCenter defaultCenter] addObserverForName:SLKUserTyping object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

		NSString *rawUserId = notification.userInfo[kSLKUserKey];
		NSString *rawChannelId = notification.userInfo[kSLKChannelKey];

		SLKUser *user = [%c(SLKUser) userForId:rawUserId contextType:1];
		SLKChannel *channel = [%c(SLKChannel) channelForId:rawChannelId contextType:1];

		NSString *userDisplayName = [user displayName];
		NSString *channelDisplayName = [channel displayTitle];

		NSString *contentString = [NSString stringWithFormat:@"is typing%@", channel ? [NSString stringWithFormat:@" in %@",channelDisplayName] : @""];

		[[[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"com.tinyspeck.chatlyio"] showNotificationWithIconName:@"TypeStatusPlusSlack" title:userDisplayName content:contentString];
	}];
}
