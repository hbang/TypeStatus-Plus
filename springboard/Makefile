include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlus
TypeStatusPlus_FILES = $(wildcard *.xm) $(wildcard *.x) $(wildcard *.m) ../Global.x
TypeStatusPlus_CFLAGS = -include ../Global.h
TypeStatusPlus_PRIVATE_FRAMEWORKS = BulletinBoard
TypeStatusPlus_EXTRA_FRAMEWORKS += Cephei TypeStatusPlusProvider

include $(THEOS_MAKE_PATH)/tweak.mk