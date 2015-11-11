include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Telegram
Telegram_FILES = $(wildcard *.m)
Telegram_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Telegram_INSTALL_PATH = /Library/TypeStatus/Providers

include $(THEOS_MAKE_PATH)/bundle.mk
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
