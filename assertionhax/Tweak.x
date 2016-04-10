#import <substrate.h>

// TODO: welp. logos should somehow support using MSFindSymbol()

static int (*_logos_orig$_ungrouped$BSAuditTokenTaskHasEntitlement)(id connection, NSString *entitlement);

_disused static int _logos_function$_ungrouped$BSAuditTokenTaskHasEntitlement(id connection, NSString *entitlement) {
	if ([entitlement isEqualToString:@"com.apple.multitasking.unlimitedassertions"]) {
		return true;
	}

	return _logos_orig$_ungrouped$BSAuditTokenTaskHasEntitlement(connection, entitlement);
}

%ctor {
	MSHookFunction(MSFindSymbol(NULL, "_BSAuditTokenTaskHasEntitlement"), (void *)_logos_function$_ungrouped$BSAuditTokenTaskHasEntitlement, (void **)&_logos_orig$_ungrouped$BSAuditTokenTaskHasEntitlement);
}
