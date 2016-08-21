INSTALL_TARGET_PROCESSES = Messenger Music Skype Slack Snapchat Telegram WhatsApp

include $(THEOS)/makefiles/common.mk

SUBPROJECTS = $(wildcard providers/*) prefs

include $(THEOS_MAKE_PATH)/aggregate.mk
