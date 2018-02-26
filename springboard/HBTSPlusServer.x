#import "HBTSPlusServer.h"
#import "HBTSPlusStateHelper.h"
#import "HBTSPlusTapToOpenController.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

@implementation HBTSPlusServer {
	CPDistributedMessagingCenter *_distributedCenter;
}

+ (instancetype)sharedInstance {
	static HBTSPlusServer *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		_distributedCenter = [CPDistributedMessagingCenter centerNamed:kHBTSPlusServerName];
		rocketbootstrap_distributedmessagingcenter_apply(_distributedCenter);
		[_distributedCenter runServerOnCurrentThread];

		[_distributedCenter registerForMessageName:kHBTSPlusServerStatusBarTappedNotificationName target:[HBTSPlusTapToOpenController sharedInstance] selector:@selector(receivedStatusBarTappedMessage:)];
		[_distributedCenter registerForMessageName:kHBTSPlusServerShowBannersNotificationName target:self selector:@selector(recievedShowBannersMessage:)];
	}
	return self;
}

- (NSDictionary *)recievedShowBannersMessage:(NSString *)message {
	// grab the value and return it
	BOOL shouldShowBanner = [HBTSPlusStateHelper shouldShowBanner];
	return @{kHBTSPlusShouldShowBannersKey: @(shouldShowBanner)};
}

@end
