%hook SBApplication

- (void)setApplicationState:(unsigned)state {
	%orig;
}

%end