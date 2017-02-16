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
#import <TypeStatusPlusProvider/HBTSNotification.h>
#import <version.h>

@interface CKConversationListCell ()

@property (nonatomic, retain) CKTypingView *_typeStatusPlus_typingIndicatorView;

@property (nonatomic, setter=_typeStatusPlus_setTypingIndicatorVisible:) BOOL _typeStatusPlus_typingIndicatorVisible;

- (void)_typeStatusPlus_setTypingIndicatorVisible:(BOOL)visible animated:(BOOL)animated;

@end

%hook CKConversationListCell

%property (nonatomic, retain) CKTypingView *_typeStatusPlus_typingIndicatorView;

- (void)updateContentsForConversation:(CKConversation *)conversation {
	%orig;

	UILabel *fromLabel = [self valueForKey:@"_fromLabel"];

	// if the from label isn’t in the view hierarchy (cell not set up yet), do
	// nothing
	if (!fromLabel.superview) {
		return;
	}

	// set up the indicator view if we haven’t already
	if (!self._typeStatusPlus_typingIndicatorView) {
		CKTypingView *typingView = [[CKTypingView alloc] init];
		typingView.alpha = 0.0;
		typingView.translatesAutoresizingMaskIntoConstraints = NO;
		typingView.layer.affineTransform = CGAffineTransformMakeScale(0.8, 0.8);

		// on ios 10, you build your own typing view!
		if (IS_IOS_OR_NEWER(iOS_10_0)) {
			typingView.indicatorLayer = [CKTypingIndicatorLayer layer];
		}
		
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
	return self._typeStatusPlus_typingIndicatorView.alpha == 1;
}

%new - (void)_typeStatusPlus_setTypingIndicatorVisible:(BOOL)visible {
	[self _typeStatusPlus_setTypingIndicatorVisible:visible animated:YES];
}

%new - (void)_typeStatusPlus_setTypingIndicatorVisible:(BOOL)visible animated:(BOOL)animated {
	// grab the summary label
	UILabel *summaryLabel = [self valueForKey:@"_summaryLabel"];

	// if animating, do things in an animation-y way. otherwise just jump to
	// what we want
	if (animated) {
		CKTypingView *typingView = self._typeStatusPlus_typingIndicatorView;
		CKTypingIndicatorLayer *layer = [typingView respondsToSelector:@selector(indicatorLayer)] ? typingView.indicatorLayer : typingView.layer;

		if (visible) {
			// fade out label; fade in indicator
			[UIView animateWithDuration:0.2 animations:^{
				summaryLabel.alpha = 0.0;
				self._typeStatusPlus_typingIndicatorView.alpha = 1.0;
			}];

			// animate it in
			[layer startGrowAnimation];
			[layer startPulseAnimation];
		} else {
			// fade out indicator; fade in label
			[UIView animateWithDuration:0.2 animations:^{
				summaryLabel.alpha = 1.0;
				self._typeStatusPlus_typingIndicatorView.alpha = 0.0;
			}];

			// animate it out
			[layer startShrinkAnimation];
		}
	} else {
		// directly change alpha values accordingly
		summaryLabel.alpha = visible ? 0.0 : 1.0;
		self._typeStatusPlus_typingIndicatorView.alpha = visible ? 1.0 : 0.0;
	}
}

- (void)prepareForReuse {
	%orig;

	// reset the typing indicator state for cell recycling
	[self _typeStatusPlus_setTypingIndicatorVisible:NO animated:NO];
}

%end

%hook CKConversationListController

- (id)init {
	self = %orig;

	if (self) {
		// register for the notification from the relay
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_typeStatusPlus_receivedNotification:) name:HBTSPlusReceiveRelayNotification object:nil];
	}

	return self;
}

- (CKConversationListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CKConversationListCell *cell = %orig;

	// sometimes the cell won’t be a conversation cell??? ok i guess we can check
	// for that and bail out if needed
	if (![cell respondsToSelector:@selector(conversation)]) {
		return cell;
	}

	// set the visibility state, which will show it if needed
	cell._typeStatusPlus_typingIndicatorVisible = [[HBTSPlusMessagesTypingManager sharedInstance] conversationIsTyping:cell.conversation];

	return cell;
}

%new - (void)_typeStatusPlus_receivedNotification:(NSNotification *)notification {
	NSString *senderName = notification.userInfo[kHBTSMessageSenderKey];
	HBTSMessageType type = (HBTSMessageType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue;

	HBTSPlusMessagesTypingManager *typingManager = [HBTSPlusMessagesTypingManager sharedInstance];

	// get all of the listed conversations
	NSArray *trackedConversations = [self.conversationList valueForKey:@"_trackedConversations"];

	// loop over them
	for (NSUInteger i = 0; i < trackedConversations.count; i++) {
		CKConversation *conversation = trackedConversations[i];

		// if it matches
		if (conversation && [conversation.name isEqualToString:[[HBTSPlusMessagesTypingManager sharedInstance] nameForHandle:senderName]]) {
			// add or remove it from the list accordingly
			switch (type) {
				case HBTSMessageTypeTyping:
					[typingManager addConversation:conversation];
					break;

				case HBTSMessageTypeTypingEnded:
					[typingManager removeConversation:conversation];
					break;

				case HBTSMessageTypeReadReceipt:
					break;
			}

			// grab the cell
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:2];
			CKConversationListCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

			// hopefully it really is a CKConversationListCell
			if ([cell respondsToSelector:@selector(conversation)]) {
				// set the indicator visibility accordingly
				cell._typeStatusPlus_typingIndicatorVisible = [typingManager conversationIsTyping:cell.conversation];
			}
		}
	}
}

%end
