NSBundle *freeBundle;
NSBundle *plusBundle;

%ctor {
	freeBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];
	plusBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlus.bundle"] retain];
}
