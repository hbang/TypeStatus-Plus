include $(THEOS)/makefiles/common.mk

SUBPROJECTS = api app messages prefs springboard $(wildcard api/providers/*)

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"