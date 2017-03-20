include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Slack
Slack_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusSlack
TypeStatusPlusSlack_FILES = Tweak.xm
TypeStatusPlusSlack_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
TypeStatusPlusSlack_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-Slack-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/$(Slack_INSTALL_PATH)/Slack.bundle$(ECHO_END)
	$(ECHO_NOTHING)ln -s ../BuiltIn.dylib $(THEOS_STAGING_DIR)/$(Slack_INSTALL_PATH)/Slack.bundle/Slack$(ECHO_END)
	
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
