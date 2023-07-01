export DEVELOPER_DIR = $(shell $(XCODES) installed $(XCODE_VERSION))
export FASTLANE_XCODEBUILD_SETTINGS_RETRIES = 1
export FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT = 60
export MINT_LINK_PATH = ./.mint/bin
export MINT_PATH = ./.mint/lib

ifdef CI
export APP_STORE_CONNECT_API_KEY_KEY_FILEPATH = $(abspath ./.secrets/AuthKey_$(APP_STORE_CONNECT_API_KEY_KEY_ID).p8)
export DERIVED_DATA_PATH = ./DerivedData
export FASTLANE_HIDE_TIMESTAMP = true
endif

FASTLANE = bundle exec fastlane
LICENSEPLIST = $(MINT_LINK_PATH)/license-plist
SWIFTLINT = $(MINT_LINK_PATH)/swiftlint
XCODES = $(MINT_LINK_PATH)/xcodes
XCODE_VERSION = $(shell cat ./.xcode-version)

APP_ROOT = ./App
APP_NAME = ios-app-template
WORKSPACE = ./$(APP_NAME).xcworkspace
PROJECT = $(APP_ROOT)/$(APP_NAME).xcodeproj
PROJECT_BASE_XCCONFIG = $(APP_ROOT)/xcconfigs/Project.base.xcconfig
SCHEMES = $(basename $(notdir $(wildcard $(PROJECT)/xcshareddata/xcschemes/*.xcscheme)))

open: bootstrap
	xed $(WORKSPACE)

bootstrap: bundle_install mint_bootstrap resolve_package_dependencies

clean: clean_build_artifacts clean_derived_data clean_mint clean_bundle

bundle_install:
	bundle check || bundle install

update_gems:
	bundle update --bundler
	bundle update

clean_bundle:
	$(eval $(shell bundle config get path --parseable))
	$(eval $(shell bundle config get bin --parseable))
	rm -rf $(path)
	rm -rf $(bin)

mint_bootstrap:
	mint bootstrap --link --verbose

clean_mint:
	rm -rf $(MINT_PATH)
	rm -rf $(MINT_LINK_PATH)

resolve_package_dependencies:
ifdef DERIVED_DATA_PATH
	xcodebuild -resolvePackageDependencies \
		-workspace $(WORKSPACE) \
		-scheme $(firstword $(SCHEMES)) \
		-derivedDataPath $(DERIVED_DATA_PATH)
else
	xcodebuild -resolvePackageDependencies \
		-workspace $(WORKSPACE) \
		-scheme $(firstword $(SCHEMES))
endif

lint:
	$(SWIFTLINT) --fix --format
	$(SWIFTLINT)

update_swiftlint_opt_in_rules:
	echo "opt_in_rules:" > ._swiftlint_opt_in_rules.yml
	$(SWIFTLINT) rules \
		| awk -F "|" '$$3 ~ "yes" && $$7 ~ "no" { if ($$5 ~ "no") { print "# -" $$2 "#" $$6 } else { print "  -" $$2 "#" $$6 } }' \
		| sed 's/\s*$$//' \
		>> ._swiftlint_opt_in_rules.yml
	mv -f ._swiftlint_opt_in_rules.yml .swiftlint_opt_in_rules.yml

generate_license:
	$(LICENSEPLIST) \
		--output-path $(APP_ROOT)/iOS/Settings.bundle \
		--fail-if-missing-license

check:
	$(FASTLANE) test \
		workspace:$(WORKSPACE) \
		scheme:$(firstword $(SCHEMES))

$(APP_STORE_CONNECT_API_KEY_KEY_FILEPATH):
	echo "$${APP_STORE_CONNECT_API_KEY_KEY}" > $@

define DEPLOY
deploy_$(1):
ifdef CI
	$(MAKE) $(APP_STORE_CONNECT_API_KEY_KEY_FILEPATH)
endif
	$(FASTLANE) deploy \
		workspace:$(WORKSPACE) \
		scheme:$(1)
endef

$(foreach scheme,$(SCHEMES),$(eval $(call DEPLOY,$(scheme))))

deploy_all: $(addprefix deploy_,$(SCHEMES))

clean_derived_data:
	xcodebuild clean -alltargets -project $(PROJECT)
	rm -rf ~/Library/Developer/Xcode/DerivedData/$(APP_NAME)-*

clean_build_artifacts:
	rm -rf ./fastlane/report.xml
	rm -rf ./fastlane/test_output
	rm -rf $(APP_ROOT)/iOS/Settings.bundle/com.mono0926.LicensePlist*
	rm -rf ./*.app.dSYM.zip
	rm -rf ./*.ipa

clean_xcode_previews_cache:
	xcrun simctl --set previews delete all

clean_swiftpm_cache:
	rm -rf ~/Library/Caches/org.swift.swiftpm
	rm -rf ~/Library/org.swift.swiftpm

set_version_number:
	$(FASTLANE) set_version_number \
		xcconfig_path:$(PROJECT_BASE_XCCONFIG) \
		version_number:$(VERSION_NUMBER)

set_build_number:
	$(FASTLANE) set_build_number \
		xcconfig_path:$(PROJECT_BASE_XCCONFIG) \
		build_number:$(BUILD_NUMBER)
