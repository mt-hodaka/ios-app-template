export FL_XCODE_VERSION = $(shell cat ./.xcode-version)
ifdef CI
export FASTLANE_HIDE_TIMESTAMP = true
export CLONED_SOURCE_PACKAGES_PATH = ./SourcePackages
endif

FASTLANE = bundle exec fastlane
BUILDTOOLS_PATH = ./BuildTools
BUILDTOOLS_CONFIGURATION = release
LICENSEPLIST = $(BUILDTOOLS_PATH)/.build/$(BUILDTOOLS_CONFIGURATION)/license-plist
SWIFTLINT = $(BUILDTOOLS_PATH)/.build/$(BUILDTOOLS_CONFIGURATION)/swiftlint
SWIFTGEN = $(BUILDTOOLS_PATH)/.build/$(BUILDTOOLS_CONFIGURATION)/swiftgen

SRCROOT = ./App
TARGET_NAME = ios-app-template
WORKSPACE = ./$(TARGET_NAME).xcworkspace
PROJECTS = $(wildcard $(SRCROOT)/*.xcodeproj)
PROJECT_NAMES = $(basename $(notdir $(PROJECTS)))
INFO_PLIST_FILE_PATHS = $(patsubst %,$(SRCROOT)/iOS/%/Info.plist,$(PROJECT_NAMES))

bootstrap: install_gems install_build_tools resolve_dependencies

clean: clean_derived_data clean_dependencies clean_build_tools clean_gems

install_gems:
ifndef CI
	rbenv install --skip-existing $(shell cat ./.ruby-version)
	rbenv exec gem install bundler
endif
	bundle check || bundle install

update_gems:
ifndef CI
	rbenv exec gem update bundler
endif
	bundle update

clean_gems:
	rm -rf ./vendor/bundle

install_build_tools:
	$(FASTLANE) install_build_tool package_path:$(BUILDTOOLS_PATH) product:$(notdir $(LICENSEPLIST)) configuration:$(BUILDTOOLS_CONFIGURATION)
	$(FASTLANE) install_build_tool package_path:$(BUILDTOOLS_PATH) product:$(notdir $(SWIFTGEN)) configuration:$(BUILDTOOLS_CONFIGURATION)
	$(FASTLANE) install_build_tool package_path:$(BUILDTOOLS_PATH) product:$(notdir $(SWIFTLINT)) configuration:$(BUILDTOOLS_CONFIGURATION)

update_build_tools:
	swift package update --package-path $(BUILDTOOLS_PATH)
	@$(MAKE) install_build_tools

clean_build_tools:
	swift package reset --package-path $(BUILDTOOLS_PATH)

resolve_dependencies:
	$(FASTLANE) resolve_dependencies \
		workspace:$(WORKSPACE) \
		scheme:"$(TARGET_NAME) ($(firstword $(PROJECT_NAMES)))"

update_dependencies: clean_dependencies
	rm $(WORKSPACE)/xcshareddata/swiftpm/Package.resolved
	@$(MAKE) resolve_dependencies
	@$(MAKE) generate_license

clean_dependencies:
ifdef CLONED_SOURCE_PACKAGES_PATH
	rm -rf $(CLONED_SOURCE_PACKAGES_PATH)
else
	rm -rf ~/Library/Developer/Xcode/DerivedData/$(TARGET_NAME)-*/SourcePackages
endif

lint:
	$(SWIFTLINT) --fix --format
	$(SWIFTLINT)

generate_license:
	$(LICENSEPLIST) \
		--output-path $(SRCROOT)/iOS/Settings.bundle \
		--package-path $(WORKSPACE)/xcshareddata/swiftpm/Package.resolved \
		--fail-if-missing-license

generate_code:
	$(SWIFTGEN) --help || exit 0

check:
	$(FASTLANE) test \
		workspace:$(WORKSPACE) \
		scheme:"$(TARGET_NAME) ($(firstword $(PROJECT_NAMES)))"

report_coverage:
	bash -c "bash <(curl -s https://codecov.io/bash) -J $(TARGET_NAME) -c"

define DEPLOY
deploy_$(1):
	$(FASTLANE) deploy \
		workspace:$(WORKSPACE) \
		scheme:"$(TARGET_NAME) ($(1))"
endef

$(foreach project,$(PROJECT_NAMES),$(eval $(call DEPLOY,$(project))))

deploy_all: $(addprefix deploy_,$(PROJECT_NAMES))

clean_derived_data:
	rm -rf ~/Library/Developer/Xcode/DerivedData/$(TARGET_NAME)-*

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
