%hook TGModernConversationTitleView
-(void)setTypingStatus:(id)arg1 activity:(int)arg2 animated:(BOOL)arg3  {
	%log;
	%orig;
	abort();
}
%end
