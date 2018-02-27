%hookf(int, "_BSAuditTokenTaskHasEntitlement", id connection, NSString *entitlement) {
	if ([entitlement isEqualToString:@"com.apple.multitasking.unlimitedassertions"]) {
		return true;
	}

	return %orig;
}
