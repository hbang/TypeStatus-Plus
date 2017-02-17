include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Snapchat
Snapchat_INSTALL_PATH = /Library/TypeStatus/Providers

include $(THEOS_MAKE_PATH)/bundle.mk

after-Snapchat-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/$(Snapchat_INSTALL_PATH)/Snapchat.bundle$(ECHO_END)
	$(ECHO_NOTHING)ln -s ../BuiltIn.dylib $(THEOS_STAGING_DIR)/$(Snapchat_INSTALL_PATH)/Snapchat.bundle/Snapchat$(ECHO_END)
	
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
