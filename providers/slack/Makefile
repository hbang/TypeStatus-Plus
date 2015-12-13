include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Slack
Slack_FILES = $(wildcard *.m)
Slack_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Slack_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusSlack
TypeStatusPlusSlack_FILES = Tweak.xm
TypeStatusPlusSlack_EXTRA_FRAMEWORKS = TypeStatusPlusProvider

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
