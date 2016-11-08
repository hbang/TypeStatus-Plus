#pragma mark - Notifications

static NSString *const HBTSClientSetStatusBarNotification = @"HBTSClientSetStatusBar";
static NSString *const HBTSSpringBoardReceivedMessageNotification = @"HBTSSpringBoardReceivedMessageNotification";
static NSString *const HBTSPlusReceiveRelayNotification = @"HBTSPlusReceiveRelayNotification";

#pragma mark - Notification constants

static NSString *const kHBTSMessageTypeKey = @"Type";
static NSString *const kHBTSMessageSenderKey = @"Name";
static NSString *const kHBTSMessageIsTypingKey = @"IsTyping";

#pragma mark - Plus notifications

static NSString *const kHBTSPlusServerName = @"ws.hbang.typestatusplus";
static NSString *const kHBTSPlusServerSetStatusBarNotificationName = @"HBTSPlusServerSetStatusBarNotification";
static NSString *const kHBTSPlusServerHideStatusBarNotificationName = @"HBTSPlusServerHideStatusBarNotification";
static NSString *const kHBTSPlusServerStatusBarTappedNotificationName = @"kHBTSPlusServerStatusBarTappedNotification";
static NSString *const kHBTSPlusServerGetUnreadCountNotificationName = @"kHBTSPlusServerGetUnreadCountNotification";
static NSString *const kHBTSPlusServerShowBannersNotificationName = @"kHBTSPlusServerShowBannersNotification";

static NSString *const kHBTSPlusShouldShowBannersKey = @"ShouldShowBanners";

static NSString *const kHBTSPlusBadgeCountKey = @"BadgeCount";

extern NSBundle *freeBundle;
extern NSBundle *plusBundle;
