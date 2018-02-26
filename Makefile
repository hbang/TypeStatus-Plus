export TARGET = iphone:11.1:9.0

INSTALL_TARGET_PROCESSES = MobileSMS Preferences

ifneq ($(RESPRING),0)
	INSTALL_TARGET_PROCESSES += SpringBoard
endif

include $(THEOS)/makefiles/common.mk

# the main bits
SUBPROJECTS = springboard prefs
# the less often updated bits
SUBPROJECTS += client messages assertionhax app

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
	$(ECHO_NOTHING)cp postinst prerm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
