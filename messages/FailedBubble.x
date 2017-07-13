#import "../global/HBTSPlusPreferences.h"

HBTSPlusPreferences *preferences;

typedef NS_ENUM(NSUInteger, CKBalloonViewColor) {
	CKBalloonViewColorGreen,
	CKBalloonViewColorBlue,
	CKBalloonViewColorWhite,
	CKBalloonViewColorRed,
	CKBalloonViewColorWhiteAgain,
	CKBalloonViewColorBlack
};

@interface CKChatItem : NSObject

@end

@interface CKBalloonChatItem : CKChatItem

@property (nonatomic, assign, readonly) BOOL failed;

@end

@interface CKMessagePartChatItem : CKBalloonChatItem

@end

%hook CKMessagePartChatItem

- (CKBalloonViewColor)color {
	return self.failed && preferences.messagesHighlightFailed ? CKBalloonViewColorRed : %orig;
}

%end

%ctor {
	preferences = [%c(HBTSPlusPreferences) sharedInstance];
}
