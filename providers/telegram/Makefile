include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Telegram
Telegram_FILES = $(wildcard *.m)
Telegram_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Telegram_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusTelegram
TypeStatusPlusTelegram_FILES = Tweak.xm
TypeStatusPlusTelegram_EXTRA_FRAMEWORKS = TypeStatusPlusProvider

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-Telegram-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/*.png $(THEOS_STAGING_DIR)/System/Library/Frameworks/UIKit.framework$(ECHO_END)
