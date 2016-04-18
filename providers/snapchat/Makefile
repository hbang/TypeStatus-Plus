include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Snapchat
Snapchat_FILES = $(wildcard *.m)
Snapchat_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Snapchat_INSTALL_PATH = /Library/TypeStatus/Providers

SUBPROJECTS = springboard

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-Snapchat-stage::
	mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
	cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework
