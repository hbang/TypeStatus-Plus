include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Music
Music_INSTALL_PATH = /Library/TypeStatus/Providers

include $(THEOS_MAKE_PATH)/bundle.mk

after-Music-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/$(Music_INSTALL_PATH)/Music.bundle$(ECHO_END)
	$(ECHO_NOTHING)ln -s ../BuiltIn.dylib $(THEOS_STAGING_DIR)/$(Music_INSTALL_PATH)/Music.bundle/Music$(ECHO_END)

	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
