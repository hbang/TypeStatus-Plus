#import <TypeStatusPlusProvider/HBTSPlusProvider.h>
#import <TypeStatusPlusProvider/HBTSPlusProviderController.h>

#define OrcaAppReceivedTyping @"OrcaAppReceivedTyping"
#define kMessengerSenderFBIDKey @"sender_fbid"
#define kMessengerStateKey @"state"

@interface FBMUserName : NSObject

@property (nonatomic, copy, readonly) NSString *firstName;
@property (nonatomic, copy, readonly) NSString *lastName;
@property (nonatomic, copy, readonly) NSString *displayName;

@end

@interface FBMUser : NSObject

@property (nonatomic, copy, readonly) FBMUserName *name;

@end

@interface FBProviderMap : NSObject

@end

@interface FBMUserFetcher

- (instancetype)initWithProviderMapData:(FBProviderMap *)providerMap;

- (void)configureAndFetchUserWithWithUserId:(NSString *)userId delegate:(id)delegate;

@end

@protocol FBMUserFetcherDelegate <NSObject>

@required

- (void)fetcher:(FBMUserFetcher *)fetcher didFetchUser:(FBMUser *)user;

- (void)fetcher:(FBMUserFetcher *)fetcher couldNotFetchUser:(NSError *)error;

@end

@interface MNAppDelegate : NSObject

@property (nonatomic, retain) FBProviderMap *providerMap;

@end

typedef void (^HBTSPlusMessengerProviderHelperCompletionBlock)(NSString *displayName);

@interface HBTSPlusMessengerProviderHelper : NSObject <FBMUserFetcherDelegate>

@property (nonatomic, copy) HBTSPlusMessengerProviderHelperCompletionBlock completionBlock;

- (void)_userDisplayNameForId:(NSString *)userId completionBlock:(HBTSPlusMessengerProviderHelperCompletionBlock)completionBlock;

@end

@implementation HBTSPlusMessengerProviderHelper

- (void)_userDisplayNameForId:(NSString *)userId completionBlock:(HBTSPlusMessengerProviderHelperCompletionBlock)completionBlock {
	_completionBlock = [completionBlock retain];

	MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];

	FBMUserFetcher *fetcher = [[%c(FBMUserFetcher) alloc] initWithProviderMapData:appDelegate.providerMap];
	[fetcher configureAndFetchUserWithWithUserId:userId delegate:self];
}

- (void)fetcher:(FBMUserFetcher *)fetcher didFetchUser:(FBMUser *)user {
	_completionBlock(user.name.displayName);
}

- (void)fetcher:(FBMUserFetcher *)fetcher couldNotFetchUser:(NSError *)error {
	HBLogError(@"The error trying to retrieve the display name is %@", error);
}

@end

%ctor {
	[[NSNotificationCenter defaultCenter] addObserverForName:OrcaAppReceivedTyping object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

		NSDictionary *userInfo = notification.userInfo;
		NSString *senderID = userInfo[kMessengerSenderFBIDKey];
		BOOL state = [userInfo[kMessengerStateKey] boolValue];

		if (state) {
			HBTSPlusMessengerProviderHelper *helper = [[HBTSPlusMessengerProviderHelper alloc] init];
			[helper _userDisplayNameForId:senderID completionBlock:^(NSString *displayName) {
				HBTSPlusProvider *messengerProvider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"com.facebook.Messenger"];
				[messengerProvider showNotificationWithIconName:@"TypeStatusPlusMessenger" title:displayName content:@"is typing"];
			}];
		} else {
			HBTSPlusProvider *messengerProvider = [[HBTSPlusProviderController sharedInstance] providerWithAppIdentifier:@"com.facebook.Messenger"];
			[messengerProvider hideNotification];
		}
	}];
}
