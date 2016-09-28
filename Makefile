INSTALL_TARGET_PROCESSES = MobileSMS Preferences

ifneq ($(RESPRING),0)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

include $(THEOS)/makefiles/common.mk

# the main bits
SUBPROJECTS = springboard api prefs
# the less often updated bits
SUBPROJECTS += client messages assertionhax app

include $(THEOS_MAKE_PATH)/aggregate.mk
