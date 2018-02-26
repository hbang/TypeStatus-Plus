%hookf(int, "_BSXPCConnectionHasEntitlement", id connection, NSString *entitlement) {
	if ([entitlement isEqualToString:@"com.apple.multitasking.unlimitedassertions"]) {
		return true;
	}

	return %orig;
}
