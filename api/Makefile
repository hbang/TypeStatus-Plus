APPLEDOCFILES = $(wildcard *.h) $(wildcard prefs/*.h)
DOCS_STAGING_DIR = _docs
DOCS_OUTPUT_PATH = docs

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = TypeStatusPlusProvider
TypeStatusPlusProvider_FILES = $(wildcard *.m) $(wildcard *.x) $(wildcard *.xm)
TypeStatusPlusProvider_PUBLIC_HEADERS = HBTSNotification.h HBTSPlusProvider.h HBTSPlusProviderController.h
TypeStatusPlusProvider_CFLAGS = -I../global -include ../global/Global.h -fobjc-arc
TypeStatusPlusProvider_FRAMEWORKS = MobileCoreServices
TypeStatusPlusProvider_PRIVATE_FRAMEWORKS = AppSupport
TypeStatusPlusProvider_EXTRA_FRAMEWORKS = Cephei CydiaSubstrate
TypeStatusPlusProvider_LIBRARIES = rocketbootstrap

include $(THEOS)/makefiles/framework.mk

docs::
	# eventually, this should probably be in theos.
	# for now, this is good enough :p

	[[ -d "$(DOCS_STAGING_DIR)" ]] && rm -r "$(DOCS_STAGING_DIR)" || true

	-appledoc --project-name "TypeStatus Plus" --project-company "HASHBANG Productions" --company-id ws.hbang \
		--project-version 1.2 --no-install-docset --keep-intermediate-files --create-html --publish-docset \
		--docset-feed-url "https://hbang.github.io/typestatus-plus/xcode-docset.atom" \
		--docset-atom-filename xcode-docset.atom --docset-package-url "https://hbang.github.io/typestatus-plus/docset.xar" \
		--docset-package-filename docset --docset-fallback-url "https://hbang.github.io/typestatus-plus/" \
		--docset-feed-name TypeStatusPlusProvider --index-desc README.md --no-repeat-first-par \
		--output "$(DOCS_STAGING_DIR)" $(APPLEDOCFILES)

	[[ -d "$(DOCS_OUTPUT_PATH)" ]] || git clone -b gh-pages git@github.com:hbang/TypeStatus-Plus.git "$(DOCS_OUTPUT_PATH)"
	rsync -ra "$(DOCS_STAGING_DIR)"/{html,publish}/ "$(DOCS_OUTPUT_PATH)"
	rm -r "$(DOCS_STAGING_DIR)"
