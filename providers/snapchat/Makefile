include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Snapchat
Snapchat_FILES = $(wildcard *.m)
Snapchat_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Snapchat_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusSnapchat
TypeStatusPlusSnapchat_FILES = Tweak.xm
TypeStatusPlusSnapchat_EXTRA_FRAMEWORKS = TypeStatusPlusProvider

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-Snapchat-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
