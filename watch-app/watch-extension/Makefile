TARGET = watchos:clang:latest:2.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TypeStatusWatch

TypeStatusWatch_FILES = InterfaceController.m $(wildcard *.m)
TypeStatusWatch_INSTALL_PATH = /Applications/TypeStatus.app/Watch/TypeStatusWatchApp.app/PlugIns
TypeStatusWatch_BUNDLE_EXTENSION = appex

include $(THEOS_MAKE_PATH)/bundle.mk
