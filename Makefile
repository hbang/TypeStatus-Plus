include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlus
TypeStatusPlus_FILES = Tweak.xm
TypeStatusPlus_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences"

SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
