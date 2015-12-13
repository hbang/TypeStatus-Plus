#import "HBTSPlusServer.h"
#import "rocketbootstrap/rocketbootstrap.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../typestatus-private/HBTSStatusBarAlertServer.h"

@implementation HBTSPlusServer

+ (instancetype)sharedInstance {
	static HBTSPlusServer *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		CPDistributedMessagingCenter *distributedCenter = [CPDistributedMessagingCenter centerNamed:HBTSPlusServerName];
		rocketbootstrap_distributedmessagingcenter_apply(distributedCenter);
		[distributedCenter runServerOnCurrentThread];
		[distributedCenter registerForMessageName:HBTSPlusServerSetStatusBarNotificationName target:self selector:@selector(receivedMessage:withUserInfo:)];
	}
	return self;
}

- (NSDictionary *)receivedMessage:(NSString *)message withUserInfo:(NSDictionary *)userInfo {
	HBLogDebug(@"Recieved message on server side.");

	NSString *title = userInfo[kHBTSPlusMessageTitleKey];
	NSString *content = userInfo[kHBTSPlusMessageContentKey];
	NSString *iconName = userInfo[kHBTSPlusMessageIconNameKey];

	[%c(HBTSStatusBarAlertServer) sendAlertWithIconName:iconName title:title content:content];

	return @{};
}

@end
