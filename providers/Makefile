INSTALL_TARGET_PROCESSES += Messenger Skype Slack Telegram WhatsApp

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = TypeStatusPlusBuiltIn
TypeStatusPlusBuiltIn_FILES = $(wildcard */*.m) $(wildcard */*.x)
TypeStatusPlusBuiltIn_PRIVATE_FRAMEWORKS = MediaRemote
TypeStatusPlusBuiltIn_EXTRA_FRAMEWORKS = CydiaSubstrate TypeStatusPlusProvider
TypeStatusPlusBuiltIn_INSTALL_PATH = /usr/lib/TypeStatus/Providers
TypeStatusPlusBuiltIn_CFLAGS = -fobjc-arc

SUBPROJECTS = $(wildcard */)

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
