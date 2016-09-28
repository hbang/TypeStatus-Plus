#import "HBTSPlusTapToOpenController.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <SpringBoard/SpringBoard.h>

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
	_appIdentifier = @"com.apple.MobileSMS";

	NSString *rawSender = notification.userInfo[kHBTSMessageSenderKey];

	if (!rawSender) {
		return;
	}

	_currentSender = [[rawSender stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]] copy];
}

- (NSDictionary *)receivedStatusBarTappedMessage:(NSString *)message {
	HBLogDebug(@"Status bar tapped—recieved notification");

	dispatch_async(dispatch_get_main_queue(), ^{
		// if this is a messages notification
		if ([_appIdentifier isEqualToString:@"com.apple.MobileSMS"]) {
			// open the url ourselves
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://open?address=%@", _currentSender]]];

			// we don’t need this any more
			_currentSender = nil;
		} else if (_actionURL) {
			// if we got a url, open that
			[[UIApplication sharedApplication] openURL:_actionURL];
		} else {
			// or fall back to just opening the app like normal
			[(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:_appIdentifier suspended:NO];
		}
	});

	return nil;
}

@end
