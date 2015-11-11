include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Slack
Slack_FILES = $(wildcard *.m)
Slack_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Slack_INSTALL_PATH = /Library/TypeStatus/Providers

include $(THEOS_MAKE_PATH)/bundle.mk
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
