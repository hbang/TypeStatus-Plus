INSTALL_TARGET_PROCESSES = MobileSMS Preferences

ifneq ($(RESPRING),0)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = api app client messages prefs springboard watch-app

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
ifeq ($(FOR_RELEASE),1)
	mkdir -p $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN
	cp postinst $(THEOS_STAGING_DIR)/DEBIAN/postrm
endif
