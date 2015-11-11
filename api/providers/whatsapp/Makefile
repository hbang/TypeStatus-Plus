include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Whatsapp
Whatsapp_FILES = $(wildcard *.m)
Whatsapp_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Whatsapp_INSTALL_PATH = /Library/TypeStatus/Providers

include $(THEOS_MAKE_PATH)/bundle.mk
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
