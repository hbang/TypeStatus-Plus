#import <IMFoundation/FZMessage.h>
#import "../Global.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <ChatKit/CKEntity.h>
#import <IMCore/IMHandle.h>

@interface CKConversationListCell : UITableViewCell {
	UILabel *_summaryLabel;
}

@end

@interface CKConversation

@property (nonatomic, readonly, retain) NSString *name;

@end

@interface CKConversationList : NSObject {
	NSMutableArray *_trackedConversations;
}

@end

@interface CKConversationListController : UITableViewController

@property (nonatomic, assign) CKConversationList *conversationList;

@end

@interface CKTranscriptTypingIndicatorCell : UIView

- (void)startPulseAnimation;
- (void)stopPulseAnimation;

@end

NSString *HBTSPlusNameForHandle(NSString *handle) {
	CKEntity *entity = [[%c(CKEntity) copyEntityForAddressString:handle] autorelease];
	return entity.name;
}

%hook CKConversationListController

- (id)init {
	if ((self = %orig)) {
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(typeStatusPlus_addInlineBubbles:) name:HBTSSpringBoardReceivedMessageNotification object:nil];
	}
	return self;
}

%new - (void)typeStatusPlus_addInlineBubbles:(NSNotification *)notification {
	NSString *senderName = notification.userInfo[kHBTSMessageSenderKey];
	NSArray *conversations = MSHookIvar<NSMutableArray *>(self.conversationList, "_trackedConversations");
	NSInteger integerInDataSource;
	for (CKConversation *conversation in conversations) {
		if ([conversation.name isEqualToString:HBTSPlusNameForHandle(senderName)]) {
			integerInDataSource = [conversations indexOfObject:conversation];
			break;
		}
	}
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:integerInDataSource inSection:2];
	CKConversationListCell *cell = (CKConversationListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	CKTranscriptTypingIndicatorCell *typingIndicator = (CKTranscriptTypingIndicatorCell *)[cell viewWithTag:38523];
	UILabel *summaryLabel = MSHookIvar<UILabel *>(cell, "_summaryLabel");
	if ([notification.userInfo[kHBTSMessageIsTypingKey] integerValue] == HBTSStatusBarTypeTyping) {
		[UIView animateWithDuration:1 animations:^{
			typingIndicator.alpha = 0.0;
			[typingIndicator stopPulseAnimation];
			[typingIndicator removeFromSuperview];
			summaryLabel.alpha = 1.0;
		}];
	} else if ([notification.userInfo[kHBTSMessageIsTypingKey] integerValue] == HBTSStatusBarTypeTypingEnded) {
		[UIView animateWithDuration:0.5 animations:^{
			summaryLabel.alpha = 0.0;
		}];
		typingIndicator = [[%c(CKTranscriptTypingIndicatorCell) alloc] init];
		typingIndicator.alpha = 0.0;
		typingIndicator.tag = 38523;
		typingIndicator.frame = CGRectMake(summaryLabel.frame.origin.x, summaryLabel.frame.origin.y+10, summaryLabel.frame.size.width, summaryLabel.frame.size.height);
		[typingIndicator startPulseAnimation];
		[cell.contentView addSubview:typingIndicator];
		[UIView animateWithDuration:0.5 animations:^{
			typingIndicator.alpha = 1.0;
		}];
	}
}

%end
