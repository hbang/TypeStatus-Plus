include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WhatsApp
WhatsApp_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusWhatsApp
TypeStatusPlusWhatsApp_FILES = Tweak.xm
TypeStatusPlusWhatsApp_EXTRA_FRAMEWORKS = TypeStatusPlusProvider

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-WhatsApp-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/$(WhatsApp_INSTALL_PATH)/WhatsApp.bundle$(ECHO_END)
	$(ECHO_NOTHING)ln -s ../BuiltIn.dylib $(THEOS_STAGING_DIR)/$(WhatsApp_INSTALL_PATH)/WhatsApp.bundle/WhatsApp$(ECHO_END)
	
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
