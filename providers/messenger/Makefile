include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Messenger
Messenger_FILES = $(wildcard *.m)
Messenger_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Messenger_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusMessenger
TypeStatusPlusMessenger_FILES = Tweak.xm
TypeStatusPlusMessenger_EXTRA_FRAMEWORKS = TypeStatusPlusProvider

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
