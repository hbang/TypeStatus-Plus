#define OrcaAppReceivedTyping @"OrcaAppReceivedTyping"
#define kMessengerSenderFBIDKey @"sender_fbid"
#define kMessengerStateKey @"state"

@interface FBMUser : NSObject

@end

@protocol FBSyncPersonLoadedListener <NSObject>

@required

- (void)didLoadPeople:(id)arg1;

@end

@interface FBAnalytics : NSObject

@end

@interface FBFileHandler : NSObject

@end

@interface MNMessengerAppKeysConfigurationProvider : NSObject

@end

@interface FBUserSession : NSObject

@end

@interface MNMessengerAppProperties : NSObject

- (instancetype)initWithSession:(FBUserSession *)session;

@end

@interface FBSessionController : NSObject

@property (nonatomic, readonly) FBUserSession *session;

@end

@interface FBSyncStore

- (instancetype)initWithSession:(FBUserSession *)userSession appProperties:(MNMessengerAppProperties *)appProperties analytics:(FBAnalytics *)analytics keysConfigurationProvider:(MNMessengerAppKeysConfigurationProvider *)keysConfigurationProvider fileHandler:(FBFileHandler *)fileHandler;

- (id)userWithId:(id)arg1 ;

@end

@interface MNAppDelegate : NSObject

@property (nonatomic,retain) FBSessionController *sessionController;

- (MNMessengerAppKeysConfigurationProvider *)keysConfigurationProvider;

@end

@interface FBSyncStorePersonSearchOperation : NSObject

@property (nonatomic, retain) id<FBSyncPersonLoadedListener> listener;

@property (retain) NSDictionary *dbStatements, *parameters;

- (void)executePersonStatement:(NSDictionary *)statement parameters:(NSDictionary *)parameters;

@end

typedef void (^HBTSPlusMessengerProviderHelperCompletionBlock)(FBMUser *user);

@interface HBTSPlusMessengerProviderHelper : NSObject <FBSyncPersonLoadedListener>

@property (nonatomic, copy) HBTSPlusMessengerProviderHelperCompletionBlock completionBlock;

@end

@implementation HBTSPlusMessengerProviderHelper

- (void)_userForId:(NSString *)userId completionBlock:(HBTSPlusMessengerProviderHelperCompletionBlock)completionBlock {

	_completionBlock = completionBlock;

	MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];

	FBSyncStore *store = [[%c(FBSyncStore) alloc] initWithSession:appDelegate.sessionController.session appProperties:[[%c(MNMessengerAppProperties) alloc] initWithSession:appDelegate.sessionController.session] analytics:nil keysConfigurationProvider:appDelegate.keysConfigurationProvider fileHandler:nil];
	FBSyncStorePersonSearchOperation *operation = [store userWithId:userId];
	operation.listener = self;
	[operation executePersonStatement:operation.dbStatements parameters:operation.parameters];
	HBLogDebug(@"sdugjxhkfhlesfdi %@", [operation performSelector:@selector(people)]);
}

- (void)didLoadPeople:(id)people {
	HBLogDebug(@"The people are %@", people);
}

@end

%hook FBSyncStore

-(id)userWithId:(id)arg1  {
	%log;
	return %orig;
}

%end

%ctor {
	[[NSNotificationCenter defaultCenter] addObserverForName:OrcaAppReceivedTyping object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

		NSDictionary *userInfo = notification.userInfo;
		NSString *senderID = userInfo[kMessengerSenderFBIDKey];


		HBTSPlusMessengerProviderHelper *helper = [[HBTSPlusMessengerProviderHelper alloc] init];
		[helper _userForId:senderID completionBlock:nil];

//		[HBTSPlusProvider showNotificationWithIconName:@"TypeStatusPlusSlack" title:userDisplayName content:contentString];
	}];
}
