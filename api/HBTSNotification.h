NS_ASSUME_NONNULL_BEGIN

/**
 * TODO: Document
 */
typedef NS_ENUM(NSUInteger, HBTSNotificationType) {
	HBTSNotificationTypeTyping,
	HBTSNotificationTypeRead = 2
};

/**
 * TODO: Document
 */
@interface HBTSNotification : NSObject

/**
 * TODO: Document
 */
@property (nonatomic, copy, nullable) NSString *sectionID;

/**
 * TODO: Document
 */
@property (nonatomic, copy, nullable) NSString *title;

/**
 * TODO: Document
 */
@property (nonatomic, copy, nullable) NSString *subtitle;

/**
 * TODO: Document
 */
@property (nonatomic, copy, nullable) NSString *content;

/**
 * TODO: Document
 */
@property (nonatomic) NSRange boldRange;

/**
 * TODO: Document
 */
@property (nonatomic, copy) NSDate *date;

/**
 * TODO: Document
 */
@property (nonatomic, copy, nullable) NSString *statusBarIconName;

/**
 * TODO: Document
 */
@property (nonatomic, copy, nullable) NSURL *actionURL;

/**
 * TODO: Document
 */
- (instancetype)initWithType:(HBTSNotificationType)type sender:(NSString *)sender iconName:(NSString *)iconName;

/**
 * TODO: Document
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 * TODO: Document
 */
- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
