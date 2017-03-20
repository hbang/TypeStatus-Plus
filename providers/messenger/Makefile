include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Messenger
Messenger_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusMessenger
TypeStatusPlusMessenger_FILES = Tweak.xm
TypeStatusPlusMessenger_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
TypeStatusPlusMessenger_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-Messenger-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/$(Messenger_INSTALL_PATH)/Messenger.bundle$(ECHO_END)
	$(ECHO_NOTHING)ln -s ../BuiltIn.dylib $(THEOS_STAGING_DIR)/$(Messenger_INSTALL_PATH)/Messenger.bundle/Messenger$(ECHO_END)

	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
