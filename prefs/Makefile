include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TypeStatusPlus
TypeStatusPlus_FILES = $(wildcard *.m)
TypeStatusPlus_INSTALL_PATH = /Library/PreferenceBundles
TypeStatusPlus_FRAMEWORKS = UIKit
TypeStatusPlus_PRIVATE_FRAMEWORKS = Preferences
TypeStatusPlus_EXTRA_FRAMEWORKS = Cephei CepheiPrefs TypeStatusPlusProvider TechSupport

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TypeStatusPlus.plist$(ECHO_END)
