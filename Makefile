include $(THEOS)/makefiles/common.mk

SUBPROJECTS = api app client messages prefs springboard watch-app

include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences"
else
	install.exec spring
endif
