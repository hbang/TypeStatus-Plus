include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlusClient
TypeStatusPlusClient_FILES = $(wildcard *.xm) $(wildcard *.x) ../global/HBTSPlusPreferences.x
TypeStatusPlusClient_CFLAGS = -I../global -include ../global/Global.h
TypeStatusPlusClient_PRIVATE_FRAMEWORKS = AppSupport
TypeStatusPlusClient_EXTRA_FRAMEWORKS = Cephei
TypeStatusPlusClient_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
