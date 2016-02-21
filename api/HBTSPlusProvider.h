#import "HBTSNotification.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * TODO: Document
 */
@interface HBTSPlusProvider : NSObject

/**
 * TODO: Document
 */
@property (nonatomic, retain) NSString *name, *appIdentifier;

/**
 * TODO: Document
 */
@property (nonatomic, retain, nullable) NSBundle *preferencesBundle;

/**
 * TODO: Document
 */
@property (nonatomic, retain, nullable) NSString *preferencesClass;

/**
 * TODO: Document
 */
- (void)showNotification:(HBTSNotification *)notification;

/**
 * @deprecated Use showNotification: instead.
 */
- (void)showNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content;

/**
 * TODO: Document
 */
- (void)hideNotification;

@end

NS_ASSUME_NONNULL_END
