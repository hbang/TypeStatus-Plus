#import "HBTSPlusTapToOpenController.h"
#import "rocketbootstrap/rocketbootstrap.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <Foundation/NSDistributedNotificationCenter.h>

@implementation HBTSPlusTapToOpenController {
	NSString *_currentSender;
}

+ (instancetype)sharedInstance {
	static HBTSPlusTapToOpenController *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	if (self = [super init]) {
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageRecieved:) name:HBTSSpringBoardReceivedMessageNotification object:nil];
	}
	return self;
}

- (void)newMessageRecieved:(NSNotification *)notification {
	[_currentSender release];

	NSString *rawSender = notification.userInfo[kHBTSMessageSenderKey];

	if (!rawSender) {
		return;
	}

	_currentSender = [[rawSender stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]] copy];
}

- (NSDictionary *)receivedStatusBarTappedMessage:(NSString *)message {
	HBLogInfo(@"Status bar tapped—recieved notification");

	if (!_currentSender) {
		return nil;
	}

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://open?address=%@", _currentSender]]];

	[_currentSender release];
	_currentSender = nil;

	return nil;
}

- (void)dealloc {
	[_currentSender release];

	[super dealloc];
}

@end
