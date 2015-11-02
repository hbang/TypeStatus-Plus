include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlus
TypeStatusPlus_FILES = $(wildcard *.xm) $(wildcard *.x) $(wildcard *.m)
TypeStatusPlus_CFLAGS = -include Global.h
TypeStatusPlus_PRIVATE_FRAMEWORKS = BulletinBoard
TypeStatusPlus_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Preferences"

SUBPROJECTS += app prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
