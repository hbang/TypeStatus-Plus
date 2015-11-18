@interface HBTSStatusBarContentItemView : UIView

@property (nonatomic, retain) NSString *text;

@end

@interface HBTSStatusBarForegroundView : UIView

@property (nonatomic, retain) UIView *containerView;

@property (nonatomic, retain) HBTSStatusBarContentItemView *contentItemView;

@end

@interface UIStatusBar: UIView

@end

%hook HBTSStatusBarForegroundView

- (void)_typeStatus_init {
	%orig;
	UITapGestureRecognizer *tapToOpenConvoRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(typeStatusPlus_openConversation:)];
	[self addGestureRecognizer:tapToOpenConvoRecognizer];
}

%new

- (void)typeStatusPlus_openConversation:(UIGestureRecognizer *)gestureRecognizer {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://open?address=%@", self.contentItemView.text]]];
	HBLogDebug(@"The address is %@", [NSString stringWithFormat:@"sms://open?address=%@", self.contentItemView.originalContactNumber]);
}

%end

%ctor {
	NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;
	if ([bundleIdentifier isEqualToString:@"com.apple.accessibility.AccessibilityUIServer"] || [bundleIdentifier isEqualToString:@"com.apple.SafariViewService"]) {
	 	return;
	}

	%init;
}