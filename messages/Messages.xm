#import <IMFoundation/FZMessage.h>
#import "../Global.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import "HBTSPlusMessagesTypingManager.h"
#import <ChatKit/CKConversation.h>
#import <Cephei/CompactConstraint.h>
#import <ChatKit/CKConversationListCell.h>
#import <ChatKit/CKConversationList.h>
#import <ChatKit/CKConversationListController.h>
#import <ChatKit/CKTranscriptTypingIndicatorCell.h>

@interface CKConversationListCell ()

@property (nonatomic, retain) CKTranscriptTypingIndicatorCell *_typeStatusPlus_typingIndicatorCell;

@property (nonatomic, setter=_typeStatusPlus_setTypingIndicatorVisible:) BOOL _typeStatusPlus_typingIndicatorVisible;

- (void)_typeStatusPlus_setTypingIndicatorVisible:(BOOL)visible animated:(BOOL)animated;

@end

%hook CKConversationListCell

%property (nonatomic, retain) CKTranscriptTypingIndicatorCell *_typeStatusPlus_typingIndicatorCell;

- (void)updateContentsForConversation:(CKConversation *)conversation {
	%orig;

	// in some situations, summaryLabel may be removed. don't do anything if that's the case
	UILabel *summaryLabel = [self valueForKey:@"_summaryLabel"];
	if (!summaryLabel.superview) {
		return;
	}

	if (!self._typeStatusPlus_typingIndicatorCell) {
		self._typeStatusPlus_typingIndicatorCell = [[CKTranscriptTypingIndicatorCell alloc] init];
		self._typeStatusPlus_typingIndicatorCell.hidden = YES;
		self._typeStatusPlus_typingIndicatorCell.translatesAutoresizingMaskIntoConstraints = NO;
		[self.contentView addSubview:self._typeStatusPlus_typingIndicatorCell];
		[self.contentView hb_addCompactConstraints:@[
			@"typingIndicatorCell.left = summaryLabel.left-4",
			@"typingIndicatorCell.top = summaryLabel.top+12"
		] metrics:nil views:@{
			@"typingIndicatorCell": self._typeStatusPlus_typingIndicatorCell,
			@"summaryLabel": summaryLabel
		}];
	}
}

%new - (BOOL)_typeStatusPlus_typingIndicatorVisible {
	return !self._typeStatusPlus_typingIndicatorCell.hidden;
}

%new - (void)_typeStatusPlus_setTypingIndicatorVisible:(BOOL)visible {
	[self _typeStatusPlus_setTypingIndicatorVisible:visible animated:YES];
}

%new - (void)_typeStatusPlus_setTypingIndicatorVisible:(BOOL)visible animated:(BOOL)animated {
	void (^completion)() = ^{
		UILabel *summaryLabel = [self valueForKey:@"_summaryLabel"];
		summaryLabel.hidden = visible;
		self._typeStatusPlus_typingIndicatorCell.hidden = !visible;
	};

	if (animated) {
		if (visible) {
			completion();
			[self._typeStatusPlus_typingIndicatorCell startGrowAnimation];
			[self._typeStatusPlus_typingIndicatorCell startPulseAnimation];
		} else {
			[self._typeStatusPlus_typingIndicatorCell startShrinkAnimation];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.20 * NSEC_PER_SEC)), dispatch_get_main_queue(), completion);
		}
	} else {
		completion();
	}
}

- (void)prepareForReuse {
	%orig;
	[self _typeStatusPlus_setTypingIndicatorVisible:NO animated:NO];
}

%end

%hook CKConversationListController

- (id)init {
	if ((self = %orig)) {
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(typeStatusPlus_addInlineBubble:) name:HBTSSpringBoardReceivedMessageNotification object:nil];
	}
	return self;
}

- (CKConversationListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CKConversationListCell *cell = %orig;

	// for some reason someone was getting a crash that it was an unknown selector, so make sure that "conversation" exists
	if (![cell respondsToSelector:@selector(conversation)]) {
		return %orig;
	}

	cell._typeStatusPlus_typingIndicatorVisible = [[HBTSPlusMessagesTypingManager sharedInstance] conversationIsTyping:cell.conversation];

	return cell;
}

%new - (void)typeStatusPlus_addInlineBubble:(NSNotification *)notification {
	NSString *senderName = notification.userInfo[kHBTSMessageSenderKey];
	BOOL isTyping = [notification.userInfo[kHBTSMessageIsTypingKey] boolValue];

	NSArray *trackedConversations = [self.conversationList valueForKey:@"_trackedConversations"];
	for (int i = 0; i < trackedConversations.count; i++) {
		CKConversation *conversation = trackedConversations[i];
		if (conversation && [conversation.name isEqualToString:[[HBTSPlusMessagesTypingManager sharedInstance] nameForHandle:senderName]]) {
			if (isTyping) {
				[[HBTSPlusMessagesTypingManager sharedInstance] addConversation:conversation];
			} else {
				[[HBTSPlusMessagesTypingManager sharedInstance] removeConversation:conversation];
			}

			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:2];

			CKConversationListCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			// for some reason someone was getting a crash that it was an unknown selector, so make sure that "conversation" exists
			if ([cell respondsToSelector:@selector(conversation)]) {
				cell._typeStatusPlus_typingIndicatorVisible = [[HBTSPlusMessagesTypingManager sharedInstance] conversationIsTyping:cell.conversation];
			}
		}
	}
}

%new - (void)typeStatusPlus_removeConversation:(CKConversation *)conversation {
	NSArray *trackedConversations = [self.conversationList valueForKey:@"_trackedConversations"];

	[[HBTSPlusMessagesTypingManager sharedInstance] removeConversation:conversation];

	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[trackedConversations indexOfObject:conversation] inSection:2];

	CKConversationListCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	cell._typeStatusPlus_typingIndicatorVisible = [[HBTSPlusMessagesTypingManager sharedInstance] conversationIsTyping:cell.conversation];
}

%end
