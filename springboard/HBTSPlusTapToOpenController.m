#import "HBTSPlusTapToOpenController.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <MobileCoreServices/LSApplicationProxy.h>
#import <MobileCoreServices/LSApplicationWorkspace.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoardServices/SpringBoardServices.h>

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
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageRecieved:) name:HBTSPlusReceiveRelayNotification object:nil];
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
			[self _openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://open?address=%@", _currentSender]] bundleIdentifier:@"com.apple.MobileSMS"];

			// we don’t need this any more
			_currentSender = nil;
		} else if (_actionURL) {
			// if we got a url, open that
			[self _openURL:_actionURL bundleIdentifier:nil];
		} else {
			// or fall back to just opening the app like normal
			[self _openURL:nil bundleIdentifier:_appIdentifier];
		}
	});

	return nil;
}

- (void)_openURL:(NSURL *)url bundleIdentifier:(NSString *)bundleIdentifier {
	if (!bundleIdentifier) {
		NSArray <LSApplicationProxy *> *apps = [[LSApplicationWorkspace defaultWorkspace] applicationsAvailableForHandlingURLScheme:url.scheme];

		if (apps.count == 0) {
			HBLogError(@"huh? no app available to open %@", url);
			return;
		}

		bundleIdentifier = apps[0].applicationIdentifier;
	}

	SBSLaunchApplicationWithIdentifierAndURLAndLaunchOptions(bundleIdentifier, url, @{}, @{
		SBSApplicationLaunchOptionUnlockDeviceKey: @YES
	}, NO);
}

@end
