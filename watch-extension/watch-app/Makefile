include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TypeStatusWatchApp

TypeStatusWatchApp_INSTALL_PATH = /Applications/TypeStatus.app/PlugIns/TypeStatusWatch.appex
TypeStatusWatchApp_BUNDLE_EXTENSION = app

include $(THEOS_MAKE_PATH)/bundle.mk

$(THEOS_OBJ_DIR)/Interface.storyboardc:: Interface.storyboard
	$(ECHO_COMPILING)xcrun ibtool --output-format human-readable-text --errors --warnings --notices --auto-activate-custom-fonts --minimum-deployment-target 9.0 --module TypeStatusWatch --compilation-directory "$(shell dirname "$@")" "$<"$(ECHO_END)
	$(ECHO_LINKING)xcrun ibtool --output-format human-readable-text --errors --warnings --notices --auto-activate-custom-fonts --minimum-deployment-target 9.0 --module TypeStatusWatch --link "$(THEOS_STAGING_DIR)$(TypeStatusWatchApp_INSTALL_PATH)/TypeStatusWatchApp.app" "$@"$(ECHO_END)
	$(ECHO_NOTHING)cp -r "$@" "$(THEOS_STAGING_DIR)$(TypeStatusWatchApp_INSTALL_PATH)/TypeStatusWatchApp.app"$(ECHO_END)

after-TypeStatusWatchApp-stage:: $(THEOS_OBJ_DIR)/Interface.storyboardc
	$(ECHO_NOTHING)mkdir -p "$(THEOS_STAGING_DIR)$(TypeStatusWatchApp_INSTALL_PATH)/TypeStatusWatchApp.app/_WatchKitStub"$(ECHO_END)
	$(ECHO_NOTHING)cp $(SYSROOT)/Library/Application\ Support/WatchKit/WK "$(THEOS_STAGING_DIR)$(TypeStatusWatchApp_INSTALL_PATH)/TypeStatusWatchApp.app/TypeStatusWatchApp"$(ECHO_END)
	$(ECHO_NOTHING)cp $(SYSROOT)/Library/Application\ Support/WatchKit/WK "$(THEOS_STAGING_DIR)$(TypeStatusWatchApp_INSTALL_PATH)/TypeStatusWatchApp.app/_WatchKitStub/WK"$(ECHO_END)
