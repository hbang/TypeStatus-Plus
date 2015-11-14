include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TypeStatusWatchApp

TypeStatusWatchApp_INSTALL_PATH = /Applications/TypeStatus.app/Watch
TypeStatusWatchApp_BUNDLE_EXTENSION = app

SUBPROJECTS = watch-extension

include $(THEOS_MAKE_PATH)/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

export WATCHAPP_DIR = $(THEOS_STAGING_DIR)$(TypeStatusWatchApp_INSTALL_PATH)/TypeStatusWatchApp.app

$(THEOS_OBJ_DIR)/Interface.storyboardc:: Interface.storyboard
	# compile storyboard
	$(ECHO_COMPILING)xcrun ibtool --output-format human-readable-text --errors --warnings --notices --auto-activate-custom-fonts --minimum-deployment-target 9.0 --module TypeStatusWatch --compilation-directory "$(shell dirname "$@")" "$<"$(ECHO_END)

	# link storyboard
	$(ECHO_LINKING)xcrun ibtool --output-format human-readable-text --errors --warnings --notices --auto-activate-custom-fonts --minimum-deployment-target 9.0 --module TypeStatusWatch --link "$(WATCHAPP_DIR)" "$@"$(ECHO_END)

$(WATCHAPP_DIR)/_WatchKitStub:: $(SYSROOT)/Library/Application\ Support/WatchKit/WK
	# copy WatchKitStub from the SDK
	$(ECHO_NOTHING)mkdir -p "$@/_WatchKitStub"$(ECHO_END)
	$(ECHO_NOTHING)cp "$<" "$@"$(ECHO_END)

after-TypeStatusWatchApp-stage:: $(THEOS_OBJ_DIR)/Interface.storyboardc
	# insert the storyboard
	$(ECHO_NOTHING)mkdir -p "$(WATCHAPP_DIR)/Base.lproj"$(ECHO_END)
	$(ECHO_NOTHING)cp -r "$<" "$(WATCHAPP_DIR)/Base.lproj"$(ECHO_END)
