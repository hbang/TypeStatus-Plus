include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlus
TypeStatusPlus_FILES = $(wildcard *.xm) $(wildcard *.x) $(wildcard *.m) ../Global.x ../HBTSPlusPreferences.x
TypeStatusPlus_CFLAGS = -include ../Global.h
TypeStatusPlus_FRAMEWORKS = AudioToolbox
TypeStatusPlus_PRIVATE_FRAMEWORKS = AppSupport BulletinBoard
TypeStatusPlus_EXTRA_FRAMEWORKS = Cephei TypeStatusPlusProvider
TypeStatusPlus_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk
