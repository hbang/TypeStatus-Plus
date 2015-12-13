include $(THEOS)/makefiles/common.mk

SUBPROJECTS = $(wildcard providers/*) prefs

include $(THEOS_MAKE_PATH)/aggregate.mk
