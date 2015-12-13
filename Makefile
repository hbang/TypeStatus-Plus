include $(THEOS)/makefiles/common.mk

SUBPROJECTS = $(wildcard providers/*)

include $(THEOS_MAKE_PATH)/aggregate.mk
