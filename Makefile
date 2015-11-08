include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlus
TypeStatusPlus_FILES = $(wildcard *.xm) $(wildcard *.x) $(wildcard *.m)
TypeStatusPlus_CFLAGS = -include Global.h
TypeStatusPlus_PRIVATE_FRAMEWORKS = BulletinBoard
TypeStatusPlus_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

FRAMEWORK_NAME = TypeStatusPlus
TypeStatusPlus_FILES = HBTSPlusProvider.m
TypeStatusPlus_PUBLIC_HEADERS = HBTSPlusProvider.h
TypeStatusPlus_EXTRA_FRAMEWORKS = Cephei
TypeStatusPlus_CFLAGS = -include Global.h

include $(THEOS_MAKE_PATH)/framework.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += app prefs messages
include $(THEOS_MAKE_PATH)/aggregate.mk
