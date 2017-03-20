export TARGET = iphone:10.1:9.0
INSTALL_TARGET_PROCESSES = Messenger Skype Slack Telegram WhatsApp

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = BuiltIn
BuiltIn_FILES = $(wildcard providers/*/*.m) $(wildcard providers/*/*.x)
BuiltIn_PRIVATE_FRAMEWORKS = MediaRemote
BuiltIn_EXTRA_FRAMEWORKS = CydiaSubstrate TypeStatusPlusProvider
BuiltIn_INSTALL_PATH = /Library/TypeStatus/Providers
BuiltIn_CFLAGS = -fobjc-arc

SUBPROJECTS = $(wildcard providers/*)

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
