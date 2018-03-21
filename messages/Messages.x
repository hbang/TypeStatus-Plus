#import "HBTSPlusPreferences.h"
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
#import <TypeStatusProvider/TypeStatusProvider.h>
#import <version.h>

HBTSPlusPreferences *preferences;

@interface CKConversationListCell ()

@property (nonatomic, retain) CKTypingView *_hb_typingIndicatorView;

- (BOOL)_hb_isTypingIndicatorVisible;
- (void)_hb_setTypingIndicatorVisible:(BOOL)visible animated:(BOOL)animated;

@end

%hook CKConversationListCell

%property (nonatomic, retain) CKTypingView *_hb_typingIndicatorView;

- (void)updateContentsForConversation:(CKConversation *)conversation {
	%orig;

	UILabel *fromLabel = [self valueForKey:@"_fromLabel"];

	// if the from label isn’t in the view hierarchy (cell not set up yet), do nothing
	if (!fromLabel.superview) {
		return;
	}

	// set up the indicator view if we haven’t already
	if (!self._hb_typingIndicatorView) {
		CKTypingView *typingView = [[CKTypingView alloc] init];
		typingView.alpha = 0.0;
		typingView.translatesAutoresizingMaskIntoConstraints = NO;

		// determine the scale of the indicator based on the dynamic type font size
		CGFloat fontSize = [UIFont preferredFontForTextStyle:UIFontTextStyleBody].pointSize;
		CGFloat scale;
		
		if (fontSize < 15) {
			scale = 0.775f;
		} else if (fontSize < 16) {
			scale = 0.875f;
		} else if (fontSize < 17) {
			scale = 0.925f;
		} else {
			scale = 1;
		}

		typingView.layer.affineTransform = CGAffineTransformMakeScale(scale, scale);

		// on ios 10, you build your own typing view!
		if (IS_IOS_OR_NEWER(iOS_10_0)) {
			Class indicatorLayerClass = %c(IMTypingIndicatorLayer) ?: %c(CKTypingIndicatorLayer);
			typingView.indicatorLayer = [indicatorLayerClass layer];
		}
		
		[self.contentView addSubview:typingView];

		[self.contentView hb_addCompactConstraints:@[
			@"typingIndicatorView.left = fromLabel.left - 1",
			@"typingIndicatorView.top = fromLabel.bottom + 3"
		] metrics:nil views:@{
			@"typingIndicatorView": typingView,
			@"fromLabel": fromLabel
		}];

		self._hb_typingIndicatorView = typingView;
	}
}

%new - (BOOL)_hb_isTypingIndicatorVisible {
	return self._hb_typingIndicatorView.alpha == 1;
}

%new - (void)_hb_setTypingIndicatorVisible:(BOOL)visible animated:(BOOL)animated {
	// if we are disabled, override both values to always be NO
	if (!preferences.messagesListTypingIndicators) {
		visible = NO;
		animated = NO;
	}

	// grab the views
	UILabel *summaryLabel = [self valueForKey:@"_summaryLabel"];
	CKTypingView *typingView = self._hb_typingIndicatorView;
	CKTypingIndicatorLayer *layer = [typingView respondsToSelector:@selector(indicatorLayer)] ? typingView.indicatorLayer : typingView.layer;

	void (^animationBlock)() = ^{
		summaryLabel.alpha = visible ? 0 : 1;
		self._hb_typingIndicatorView.alpha = visible ? 1 : 0;
	};

	// if animating, do things in an animation-y way. otherwise just jump to what we want
	if (animated) {
		[UIView animateWithDuration:0.2 animations:animationBlock];

		// animate a grow or shrink based on the direction we’re moving to
		if (visible) {
			[layer startGrowAnimation];
		} else {
			[layer startShrinkAnimation];
		}
	} else {
		// call the animation block directly without animating
		animationBlock();
	}

	// regardless of animation, we need to ensure it’s pulsing if visible
	if (visible) {
		[layer startPulseAnimation];
	}
}

- (void)prepareForReuse {
	%orig;

	// reset the typing indicator state for cell recycling
	[self _hb_setTypingIndicatorVisible:NO animated:NO];
}

%end

%hook CKConversationListController

- (id)init {
	self = %orig;

	if (self) {
		// register for the notification from the relay
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_hb_receivedRelayNotification:) name:HBTSPlusReceiveRelayNotification object:nil];
	}

	return self;
}

- (CKConversationListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CKConversationListCell *cell = %orig;

	// sometimes the cell won’t be a conversation cell??? ok i guess we can check for that and bail
	// out if needed
	if (![cell respondsToSelector:@selector(conversation)]) {
		return cell;
	}

	// set the visibility state, which will show it if needed
	BOOL isTyping = [[HBTSPlusMessagesTypingManager sharedInstance] conversationIsTyping:cell.conversation];
	[cell _hb_setTypingIndicatorVisible:isTyping animated:NO];

	return cell;
}

%new - (void)_hb_receivedRelayNotification:(NSNotification *)notification {
	NSString *senderName = notification.userInfo[kHBTSMessageSenderKey];
	HBTSMessageType type = (HBTSMessageType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).integerValue;

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
				case HBTSMessageTypeSendingFile:
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
				[cell _hb_setTypingIndicatorVisible:[typingManager conversationIsTyping:cell.conversation] animated:YES];
			}
		}
	}
}

%end

%ctor {
	preferences = [%c(HBTSPlusPreferences) sharedInstance];
}
