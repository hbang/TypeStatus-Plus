include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlusClient
TypeStatusPlusClient_FILES = $(wildcard *.xm) $(wildcard *.x)
TypeStatusPlusClient_CFLAGS = -include ../Global.h
TypeStatusPlusClient_PRIVATE_FRAMEWORKS = AppSupport
TypeStatusPlusClient_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
