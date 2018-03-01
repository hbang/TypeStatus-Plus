#pragma mark - Notifications

static NSString *const HBTSClientSetStatusBarNotification = @"HBTSClientSetStatusBar";
static NSString *const HBTSPlusReceiveRelayNotification = @"HBTSPlusReceiveRelayNotification";
static NSString *const HBTSPlusUnreadCountChangedNotification = @"HBTSPlusUnreadCountChangedNotification";
static NSString *const HBTSPlusGiveMeTheUnreadCountNotification = @"HBTSPlusGiveMeTheUnreadCountNotification";

#pragma mark - Notification constants

static NSString *const kHBTSMessageTypeKey = @"Type";
static NSString *const kHBTSMessageSenderKey = @"Name";

#pragma mark - Plus notifications

static NSString *const kHBTSPlusServerName = @"ws.hbang.typestatusplus";
static NSString *const kHBTSPlusServerStatusBarTappedNotificationName = @"kHBTSPlusServerStatusBarTappedNotification";
static NSString *const kHBTSPlusServerShowBannersNotificationName = @"kHBTSPlusServerShowBannersNotification";

static NSString *const kHBTSPlusShouldShowBannersKey = @"ShouldShowBanners";

static NSString *const kHBTSPlusBadgeCountKey = @"BadgeCount";
