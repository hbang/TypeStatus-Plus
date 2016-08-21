%hook SKPConversation

- (void)replaceTypingParticipantsAtIndexes:(id)fp8 withTypingParticipants:(id)fp12 {
	%log;
	%orig;
}

- (void)removeTypingParticipantsAtIndexes:(id)fp8 {
	%log;
	%orig;
}

- (void)insertTypingParticipants:(id)a atIndexes:(id)b {
	%log;
	%orig;
}

%end

%hook SKPParticipant

- (BOOL)isTyping {
	%log;
	BOOL r = %orig;
	HBLogDebug(@" --> %i",r);
	if(r)abort();
	return r;
}

%end

%hook NSObject
-(void)didChangeValueForKey:(NSString *)k{
	%log;
	if ([k isEqualToString:@"typing"] && ((NSNumber *)[self valueForKey:@"typing"]).boolValue) abort();
	%orig;
}
%end
