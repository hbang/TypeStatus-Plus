NSBundle *freeBundle;
NSBundle *plusBundle;

%ctor {
	freeBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"];
	plusBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlus.bundle"];
}
