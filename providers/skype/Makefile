include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Skype
Skype_FILES = $(wildcard *.m)
Skype_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Skype_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusSkype
TypeStatusPlusSkype_FILES = Tweak.xm
TypeStatusPlusSkype_EXTRA_FRAMEWORKS = TypeStatusPlusProvider

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-Skype-stage::
	mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
	cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
