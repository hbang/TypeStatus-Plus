INSTALL_TARGET_PROCESSES = MobileSMS Preferences

ifneq ($(RESPRING),0)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = api app assertionhax client messages prefs springboard

include $(THEOS_MAKE_PATH)/aggregate.mk
