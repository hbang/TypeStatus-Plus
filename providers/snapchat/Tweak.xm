%hook SCChats

+(void)sendTypingNotificationWithParameters:(id)parameters successBlock:(id)block failureBlock:(id)block3 {
	%orig;
	%log;
}

%end
