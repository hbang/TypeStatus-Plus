#define OrcaAppReceivedTyping @"OrcaAppReceivedTyping"
#define kMessengerSenderFBIDKey @"sender_fbid"
#define kMessengerStateKey @"state"

@class FBUserSession;

@interface MNMessagesSyncThreadKey : NSObject

@property (nonatomic) long long otherUserFbId;

@end

@interface MNMessagesSyncDeltaReadReceipt : NSObject

@property (nonatomic) long long actorFbId;
@property (retain, nonatomic) MNMessagesSyncThreadKey *threadKey;

@end

@interface FBMUserName : NSObject

@property (nonatomic, copy, readonly) NSString *firstName;
@property (nonatomic, copy, readonly) NSString *lastName;
@property (nonatomic, copy, readonly) NSString *displayName;

@end

@interface FBMUser : NSObject

@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) FBMUserName *name;

@end

@protocol FBDependencyProviding <NSObject>

@end

@interface FBProviderMap : NSObject <FBDependencyProviding>

@end

@interface FBMUserFetcher : NSObject

- (instancetype)initWithDependencyProvider:(id <FBDependencyProviding>)dependencyProvider;

- (void)configureAndFetchUserWithWithUserId:(NSString *)userId delegate:(id)delegate;

@end

@protocol FBMUserFetcherDelegate <NSObject>

@required

- (void)fetcher:(FBMUserFetcher *)fetcher didFetchUser:(FBMUser *)user;

- (void)fetcher:(FBMUserFetcher *)fetcher couldNotFetchUser:(NSError *)error;

@end

@interface MNAppDelegate : NSObject

@end
