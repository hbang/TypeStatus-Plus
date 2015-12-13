#import <IMFoundation/FZMessage.h>
#import "../Global.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <ChatKit/CKEntity.h>
#import <IMCore/IMHandle.h>

static CGFloat const kHBTSPlusInlineTypingIndicatorViewTag = 38523;

@interface CKConversation

@property (nonatomic, readonly, retain) NSString *name;

@end

@interface CKConversationListCell : UITableViewCell {
	UILabel *_summaryLabel;
}

@property (nonatomic, retain) CKConversation *conversation;

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
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(typeStatusPlus_addInlineBubble:) name:HBTSSpringBoardReceivedMessageNotification object:nil];
	}
	return self;
}

/* TODO: make it so that the indicator does not appear on other cells while scrolling
- (CKConversationListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CKConversationListCell *cell = %orig;
	return cell;
}
*/

%new - (void)typeStatusPlus_addInlineBubble:(NSNotification *)notification {
	NSString *senderName = notification.userInfo[kHBTSMessageSenderKey];
	BOOL isTyping = [notification.userInfo[kHBTSMessageIsTypingKey] boolValue];

	CKConversationListCell *cell;
	for (CKConversationListCell *conversationCell in [self.tableView visibleCells]) {
		if (conversationCell.conversation && conversationCell.conversation.name && [conversationCell.conversation.name isEqualToString:HBTSPlusNameForHandle(senderName)]) {
			cell = conversationCell;
			break;
		}
	}

	if (cell) {
		if (isTyping) {
			UILabel *summaryLabel = [cell valueForKey:@"_summaryLabel"];

			CKTranscriptTypingIndicatorCell *typingIndicator = [[%c(CKTranscriptTypingIndicatorCell) alloc] init];
			typingIndicator.alpha = 0.0;
			typingIndicator.tag = kHBTSPlusInlineTypingIndicatorViewTag;
			typingIndicator.frame = CGRectMake(summaryLabel.frame.origin.x-4, summaryLabel.frame.origin.y+12, summaryLabel.frame.size.width, summaryLabel.frame.size.height);
			[typingIndicator startPulseAnimation];
			[cell.contentView addSubview:typingIndicator];

			[UIView animateWithDuration:0.5 animations:^{
				summaryLabel.alpha = 0.0;
				typingIndicator.alpha = 1.0;
			}];

			[self performSelector:@selector(typeStatusPlus_removeInlineBubbleForCell:) withObject:cell afterDelay:5];
		} else {
			[self performSelector:@selector(typeStatusPlus_removeInlineBubbleForCell:) withObject:cell];
		}
	}
}

%new

- (void)typeStatusPlus_removeInlineBubbleForCell:(CKConversationListCell *)cell {
	if (cell) {
		CKTranscriptTypingIndicatorCell *indicatorCell = [cell viewWithTag:kHBTSPlusInlineTypingIndicatorViewTag];
		if (indicatorCell) {
			UILabel *summaryLabel = [cell valueForKey:@"_summaryLabel"];

			[UIView animateWithDuration:0.5 animations:^{
				[indicatorCell stopPulseAnimation];
				indicatorCell.alpha = 0.0;

				summaryLabel.alpha = 1.0;
			} completion:^(BOOL completion) {
				[indicatorCell removeFromSuperview];
				[indicatorCell release];
			}];
		}
	}
}

%end
