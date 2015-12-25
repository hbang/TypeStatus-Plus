APPLEDOCFILES = $(wildcard *.h) $(wildcard prefs/*.h)
DOCS_STAGING_DIR = _docs
DOCS_OUTPUT_PATH = docs

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = TypeStatusPlusProvider
TypeStatusPlusProvider_FILES = HBTSPlusProviderController.m HBTSPlusProvider.x Loading.xm
TypeStatusPlusProvider_PUBLIC_HEADERS = HBTSPlusProvider.h HBTSPlusProviderController.h
TypeStatusPlusProvider_PRIVATE_FRAMEWORKS = AppSupport
TypeStatusPlusProvider_EXTRA_FRAMEWORKS = Cephei
TypeStatusPlusProvider_LIBRARIES = rocketbootstrap substrate
TypeStatusPlusProvider_CFLAGS = -include ../Global.h

TWEAK_NAME = TypeStatusPlusBackgrounding
TypeStatusPlusBackgrounding_FILES = Backgrounding.xm ../HBTSPlusPreferences.x
TypeStatusPlusBackgrounding_EXTRA_FRAMEWORKS = Cephei

include $(THEOS)/makefiles/framework.mk
include $(THEOS)/makefiles/tweak.mk

after-TypeStatusPlusProvider-all::
	# create directories
	mkdir -p $(THEOS_OBJ_DIR)/TypeStatusPlusProvider.framework/Headers

	# copy headers
	rsync -ra $(TypeStatusPlusProvider_PUBLIC_HEADERS) $(THEOS_OBJ_DIR)/TypeStatusPlusProvider.framework/Headers

	# copy to theos lib dir
	rsync -ra $(THEOS_OBJ_DIR)/TypeStatusPlusProvider.framework $(THEOS)/lib

docs::
	# eventually, this should probably be in theos.
	# for now, this is good enough :p

	[[ -d "$(DOCS_STAGING_DIR)" ]] && rm -r "$(DOCS_STAGING_DIR)" || true

	-appledoc --project-name TypeStatus\ Plus --project-company "HASHBANG Productions" --company-id ws.hbang \
		--project-version 1.2 --no-install-docset --keep-intermediate-files --create-html --publish-docset \
		--docset-feed-url "https://hbang.github.io/typestatus-plus/xcode-docset.atom" \
		--docset-atom-filename xcode-docset.atom --docset-package-url "https://hbang.github.io/typestatus-plus/docset.xar" \
		--docset-package-filename docset --docset-fallback-url "https://hbang.github.io/typestatus-plus/" \
		--docset-feed-name TypeStatusPlusProvider --index-desc README.md --no-repeat-first-par \
		--output "$(DOCS_STAGING_DIR)" $(APPLEDOCFILES)

	[[ -d "$(DOCS_OUTPUT_PATH)" ]] || git clone -b gh-pages git@github.com:hbang/TypeStatus-Plus.git "$(DOCS_OUTPUT_PATH)"
	rsync -ra "$(DOCS_STAGING_DIR)"/{html,publish}/ "$(DOCS_OUTPUT_PATH)"
	rm -r "$(DOCS_STAGING_DIR)"
