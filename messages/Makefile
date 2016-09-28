include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlusMessages
TypeStatusPlusMessages_FILES = $(wildcard *.x)
TypeStatusPlusMessages_CFLAGS = -I../global -include ../global/Global.h -fobjc-arc
TypeStatusPlusMessages_PRIVATE_FRAMEWORKS = ChatKit
TypeStatusPlusMessages_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall MobileSMS"
