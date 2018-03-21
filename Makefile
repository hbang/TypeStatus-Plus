export TARGET = iphone:latest:9.0

INSTALL_TARGET_PROCESSES = MobileSMS Preferences Messenger Skype Slack Telegram WhatsApp

ifneq ($(RESPRING),0)
	INSTALL_TARGET_PROCESSES += SpringBoard
endif

export ADDITIONAL_CFLAGS = -fobjc-arc -Wextra -Wno-unused-parameter \
	-I$(THEOS_PROJECT_DIR)/global -include $(THEOS_PROJECT_DIR)/global/Global.h

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlus TypeStatusPlusClient TypeStatusPlusMessages TypeStatusPlusAssertiond

TypeStatusPlus_FILES = $(wildcard springboard/*.[xm])
TypeStatusPlus_FRAMEWORKS = AudioToolbox MobileCoreServices
TypeStatusPlus_PRIVATE_FRAMEWORKS = AppSupport BackBoardServices BulletinBoard FrontBoardServices
TypeStatusPlus_EXTRA_FRAMEWORKS = Cephei TypeStatusProvider
TypeStatusPlus_LIBRARIES = rocketbootstrap

TypeStatusPlusClient_FILES = $(wildcard client/*.[xm])
TypeStatusPlusClient_PRIVATE_FRAMEWORKS = AppSupport MobileCoreServices
TypeStatusPlusClient_EXTRA_FRAMEWORKS = Cephei TypeStatusProvider
TypeStatusPlusClient_LIBRARIES = rocketbootstrap

TypeStatusPlusMessages_FILES = $(wildcard messages/*.[xm])
TypeStatusPlusMessages_PRIVATE_FRAMEWORKS = ChatKit
TypeStatusPlusMessages_EXTRA_FRAMEWORKS = Cephei

TypeStatusPlusAssertiond_FILES = assertionhax/Tweak.x
TypeStatusPlusAssertiond_PRIVATE_FRAMEWORKS = BaseBoard

LIBRARY_NAME = TypeStatusPlusBuiltIn

TypeStatusPlusBuiltIn_FILES = $(wildcard providers/*.[xm])
TypeStatusPlusBuiltIn_PRIVATE_FRAMEWORKS = MediaRemote
TypeStatusPlusBuiltIn_EXTRA_FRAMEWORKS = CydiaSubstrate TypeStatusProvider
TypeStatusPlusBuiltIn_INSTALL_PATH = /Library/TypeStatus/Providers

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/library.mk

SUBPROJECTS = prefs app

include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
ifneq ($(PACKAGE_BUILDNAME)$(ASSERTIOND),debug)
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
	$(ECHO_NOTHING)cp postinst postrm $(THEOS_STAGING_DIR)/DEBIAN$(ECHO_END)
endif
