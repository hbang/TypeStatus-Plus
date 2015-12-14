include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypeStatusPlusMessages
TypeStatusPlusMessages_FILES = Messages.xm HBTSPlusMessagesTypingManager.x
TypeStatusPlusMessages_PRIVATE_FRAMEWORKS = ChatKit
TypeStatusPlusMessages_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 com.apple.MobileSMS"
