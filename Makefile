export FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT = 60
export FASTLANE_XCODEBUILD_SETTINGS_RETRIES = 1
export MINT_PATH = ./.mint/lib
export MINT_LINK_PATH = ./.mint/bin
export FL_XCODES_BINARY_PATH = $(MINT_LINK_PATH)/xcodes

ifdef CI
export FASTLANE_HIDE_TIMESTAMP = true
export CLONED_SOURCE_PACKAGES_PATH = ./SourcePackages
endif

FASTLANE = bundle exec fastlane
BUILDTOOLS_ROOT = ./BuildTools
BUILDTOOLS_PACKAGE_PATHS = $(dir $(wildcard $(BUILDTOOLS_ROOT)/*/Package.swift))
BUILDTOOLS_CONFIGURATION = release
LICENSEPLIST = $(MINT_LINK_PATH)/license-plist
SWIFTLINT = $(MINT_LINK_PATH)/swiftlint

APP_ROOT = ./App
APP_NAME = ios-app-template
WORKSPACE = ./$(APP_NAME).xcworkspace
PROJECT = $(APP_ROOT)/$(APP_NAME).xcodeproj
SCHEMES = $(basename $(notdir $(wildcard $(PROJECT)/xcshareddata/xcschemes/*.xcscheme)))
INFO_PLIST_FILE_PATHS = $(wildcard $(APP_ROOT)/iOS/Env/*/Info.plist)

bootstrap: install_gems install_build_tools resolve_dependencies

clean: clean_build_artifacts clean_derived_data clean_dependencies clean_build_tools clean_gems

install_gems:
	bundle check || bundle install

update_gems:
	bundle update --bundler
	bundle update

clean_gems:
	rm -rf ./vendor/bundle

install_build_tools:
	mint bootstrap --link --verbose

clean_build_tools:
	rm -rf $(MINT_PATH)
	rm -rf $(MINT_LINK_PATH)

resolve_dependencies:
	$(FASTLANE) resolve_dependencies \
		workspace:$(WORKSPACE) \
		scheme:$(firstword $(SCHEMES))

update_dependencies: clean_dependencies
	rm $(WORKSPACE)/xcshareddata/swiftpm/Package.resolved
	@$(MAKE) resolve_dependencies
	@$(MAKE) generate_license

clean_dependencies:
ifdef CLONED_SOURCE_PACKAGES_PATH
	rm -rf $(CLONED_SOURCE_PACKAGES_PATH)
else
	rm -rf ~/Library/Developer/Xcode/DerivedData/$(APP_NAME)-*/SourcePackages
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
		--package-path $(WORKSPACE)/xcshareddata/swiftpm/Package.resolved \
		--fail-if-missing-license

check:
	$(FASTLANE) test \
		workspace:$(WORKSPACE) \
		scheme:$(firstword $(SCHEMES))

report_coverage:
	bash -c "bash <(curl -s https://codecov.io/bash) -J $(APP_NAME) -c"

define DEPLOY
deploy_$(1):
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

current_version:
	$(FASTLANE) current_version \
		info_plist_path:$(firstword $(INFO_PLIST_FILE_PATHS))

bump_version_number:
ifdef VERSION_NUMBER
	$(FASTLANE) bump_version_number \
		info_plist_paths:"$(INFO_PLIST_FILE_PATHS)" \
		version_number:$(VERSION_NUMBER)
else
	$(FASTLANE) bump_version_number \
		info_plist_paths:"$(INFO_PLIST_FILE_PATHS)"
endif

bump_build_number:
ifdef BUILD_NUMBER
	$(FASTLANE) bump_build_number \
		info_plist_paths:"$(INFO_PLIST_FILE_PATHS)" \
		build_number:$(BUILD_NUMBER)
else
	$(FASTLANE) bump_build_number \
		info_plist_paths:"$(INFO_PLIST_FILE_PATHS)" \
		build_number:$(shell git rev-list HEAD --merges | wc -l | tr -d ' ')
endif

get_commit_hash_at_build_number:
	git rev-list HEAD --merges | tail -r | sed -n $(BUILD_NUMBER)p
