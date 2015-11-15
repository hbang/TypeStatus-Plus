include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Whatsapp
Whatsapp_FILES = $(wildcard *.m)
Whatsapp_EXTRA_FRAMEWORKS = TypeStatusPlusProvider
Whatsapp_INSTALL_PATH = /Library/TypeStatus/Providers

TWEAK_NAME = TypeStatusPlusWhatsApp
TypeStatusPlusWhatsApp_FILES = Tweak.xm
TypeStatusPlusWhatsApp_EXTRA_FRAMEWORKS = TypeStatusPlusProvider

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
