export TARGET = iphone:10.1:9.0

INSTALL_TARGET_PROCESSES = Messenger Skype Slack Telegram WhatsApp

ifeq ($(RESPRING),1)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = TypeStatusPlusBuiltIn
TypeStatusPlusBuiltIn_FILES = $(wildcard providers/*/*.m) $(wildcard providers/*/*.x)
TypeStatusPlusBuiltIn_PRIVATE_FRAMEWORKS = MediaRemote
TypeStatusPlusBuiltIn_EXTRA_FRAMEWORKS = CydiaSubstrate TypeStatusPlusProvider
TypeStatusPlusBuiltIn_INSTALL_PATH = /Library/TypeStatus/Providers
TypeStatusPlusBuiltIn_CFLAGS = -fobjc-arc

SUBPROJECTS = $(wildcard providers/*)

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
