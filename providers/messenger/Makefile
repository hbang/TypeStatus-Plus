include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Messenger
Messenger_FILES = $(wildcard *.m)
Messenger_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Messenger_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusMessenger
TypeStatusPlusMessenger_FILES = Tweak.xm
TypeStatusPlusMessenger_EXTRA_FRAMEWORKS = TypeStatusPlusProvider

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-Messenger-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
