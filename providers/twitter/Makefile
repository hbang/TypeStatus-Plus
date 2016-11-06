include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TwitterProvider
TwitterProvider_FILES = $(wildcard *.m)
TwitterProvider_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
TwitterProvider_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusTwitter
TypeStatusPlusTwitter_FILES = Tweak.xm
TypeStatusPlusTwitter_EXTRA_FRAMEWORKS = TypeStatusPlusProvider

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-Twitter-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
