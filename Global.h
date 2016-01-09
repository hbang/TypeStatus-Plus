#pragma mark - From TypeStatus

typedef NS_ENUM(NSUInteger, HBTSStatusBarType) {
	HBTSStatusBarTypeTyping,
	HBTSStatusBarTypeTypingEnded,
	HBTSStatusBarTypeRead
};

typedef NS_ENUM(NSUInteger, HBTSNotificationType) {
	HBTSNotificationTypeNone,
	HBTSNotificationTypeOverlay,
	HBTSNotificationTypeIcon
};

typedef NS_ENUM(NSUInteger, HBTSStatusBarAnimation) {
	HBTSStatusBarAnimationSlide,
	HBTSStatusBarAnimationFade
};

static NSTimeInterval const kHBTSTypingTimeout = 60.0;

/*
 old notification name is used here for compatibility with
 tweaks that listen into typestatus' notifications
*/

static NSString *const HBTSClientSetStatusBarNotification = @"HBTSClientSetStatusBar";
static NSString *const HBTSSpringBoardReceivedMessageNotification = @"HBTSSpringBoardReceivedMessageNotification";

static NSString *const kHBTSPlusServerName = @"ws.hbang.typestatusplus";
static NSString *const kHBTSPlusServerSetStatusBarNotificationName = @"HBTSPlusServerSetStatusBarNotificationName";
static NSString *const kHBTSPlusServerHideStatusBarNotificationName = @"HBTSPlusServerHideStatusBarNotificationName";
static NSString *const kHBTSPlusServerStatusBarTappedNotificationName = @"kHBTSPlusServerStatusBarTappedNotificationName";
static NSString *const kHBTSPlusServerGetUnreadCountNotificationName = @"kHBTSPlusServerGetUnreadCountNotificationName";

static NSString *const kHBTSPlusBadgeCountKey = @"BadgeCount";

static NSString *const kHBTSPlusMessageTitleKey = @"Title";
static NSString *const kHBTSPlusMessageContentKey = @"Content";
static NSString *const kHBTSPlusMessageIconNameKey = @"IconName";
static NSString *const kHBTSPlusAppIdentifierKey = @"AppIdentifier";

static NSString *const kHBTSMessageTypeKey = @"Type";
static NSString *const kHBTSMessageSenderKey = @"Name";
static NSString *const kHBTSMessageIsTypingKey = @"IsTyping";
static NSString *const kHBTSMessageDurationKey = @"Duration";
static NSString *const kHBTSMessageSendDateKey = @"Date";

#pragma mark - Plus

extern NSBundle *freeBundle;
extern NSBundle *plusBundle;
