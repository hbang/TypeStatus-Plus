include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlus
TypeStatusPlus_FILES = $(wildcard *.xm) $(wildcard *.x) $(wildcard *.m)
TypeStatusPlus_CFLAGS = -I../global -include ../global/Global.h -fobjc-arc -F$(THEOS)/lib/TypeStatusProvider.framework
TypeStatusPlus_FRAMEWORKS = AudioToolbox
TypeStatusPlus_PRIVATE_FRAMEWORKS = AppSupport BackBoardServices BulletinBoard FrontBoardServices MobileCoreServices
TypeStatusPlus_EXTRA_FRAMEWORKS = Cephei TypeStatusProvider
TypeStatusPlus_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk
