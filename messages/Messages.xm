#import "../global/Global.h"
#import "HBTSPlusMessagesTypingManager.h"
#import <Cephei/CompactConstraint.h>
#import <ChatKit/CKConversation.h>
#import <ChatKit/CKConversationList.h>
#import <ChatKit/CKConversationListCell.h>
#import <ChatKit/CKConversationListController.h>
#import <ChatKit/CKTypingView.h>
#import <ChatKit/CKTypingIndicatorLayer.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <IMFoundation/FZMessage.h>

@interface CKConversationListCell ()

@property (nonatomic, retain) CKTypingView *_typeStatusPlus_typingIndicatorView;

@property (nonatomic, setter=_typeStatusPlus_setTypingIndicatorVisible:) BOOL _typeStatusPlus_typingIndicatorVisible;

- (void)_typeStatusPlus_setTypingIndicatorVisible:(BOOL)visible animated:(BOOL)animated;

@end

%hook CKConversationListCell

%property (nonatomic, retain) CKTypingView *_typeStatusPlus_typingIndicatorView;

- (void)updateContentsForConversation:(CKConversation *)conversation {
	%orig;

	// in some situations, fromLabel may be removed. don't do anything if that's the case
	UILabel *fromLabel = [self valueForKey:@"_fromLabel"];
	if (!fromLabel.superview) {
		return;
	}

	if (!self._typeStatusPlus_typingIndicatorView) {
		CKTypingView *typingView = [[CKTypingView alloc] init];
		typingView.hidden = YES;
		typingView.translatesAutoresizingMaskIntoConstraints = NO;
		typingView.layer.affineTransform = CGAffineTransformMakeScale(0.8, 0.8);
		[self.contentView addSubview:typingView];
		[self.contentView hb_addCompactConstraints:@[
			@"typingIndicatorView.left = fromLabel.left - 1",
			@"typingIndicatorView.top = fromLabel.bottom + 2"
		] metrics:nil views:@{
			@"typingIndicatorView": typingView,
			@"fromLabel": fromLabel
		}];

		self._typeStatusPlus_typingIndicatorView = typingView;
	}
}

%new - (BOOL)_typeStatusPlus_typingIndicatorVisible {
	return !self._typeStatusPlus_typingIndicatorView.hidden;
}

%new - (void)_typeStatusPlus_setTypingIndicatorVisible:(BOOL)visible {
	[self _typeStatusPlus_setTypingIndicatorVisible:visible animated:YES];
}

%new - (void)_typeStatusPlus_setTypingIndicatorVisible:(BOOL)visible animated:(BOOL)animated {
	// if we’re already visible then don’t bother
	if (visible == !self._typeStatusPlus_typingIndicatorView.hidden) {
		return;
	}

	UILabel *summaryLabel = [self valueForKey:@"_summaryLabel"];

	if (animated) {
		if (visible) {
			summaryLabel.alpha = 1;

			[UIView animateWithDuration:0.2 animations:^{
				summaryLabel.alpha = 0;
			} completion:^(BOOL finished) {
				summaryLabel.alpha = 1;
				summaryLabel.hidden = YES;
			}];

			self._typeStatusPlus_typingIndicatorView.hidden = NO;
			[self._typeStatusPlus_typingIndicatorView.layer startGrowAnimation];
			[self._typeStatusPlus_typingIndicatorView.layer startPulseAnimation];
		} else {
			summaryLabel.alpha = 0;
			summaryLabel.hidden = NO;

			[UIView animateWithDuration:0.2 animations:^{
				summaryLabel.alpha = 1;
			} completion:^(BOOL finished) {
				self._typeStatusPlus_typingIndicatorView.hidden = YES;
			}];

			[self._typeStatusPlus_typingIndicatorView.layer startShrinkAnimation];
		}
	} else {
		summaryLabel.hidden = visible;
		self._typeStatusPlus_typingIndicatorView.hidden = !visible;
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
