export FL_XCODE_VERSION = $(shell cat ./.xcode-version)
ifdef CI
export FASTLANE_HIDE_TIMESTAMP = true
export CLONED_SOURCE_PACKAGES_PATH = ~/Library/Caches/SourcePackages
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

bootstrap: prepare-gems prepare-build-tools

clean: clean-gems clean-build-tools

prepare-gems:
ifndef CI
	rbenv install --skip-existing $(shell cat ./.ruby-version)
	rbenv exec gem install bundler
endif
	bundle check || bundle install

update-gems:
ifndef CI
	rbenv exec gem update bundler
endif
	bundle update

clean-gems:
	rm -rf ./vendor/bundle

prepare-build-tools:
	$(FASTLANE) prepare_build_tool package_path:$(BUILDTOOLS_PATH) product:$(notdir $(LICENSEPLIST)) configuration:$(BUILDTOOLS_CONFIGURATION)
	$(FASTLANE) prepare_build_tool package_path:$(BUILDTOOLS_PATH) product:$(notdir $(SWIFTGEN)) configuration:$(BUILDTOOLS_CONFIGURATION)
	$(FASTLANE) prepare_build_tool package_path:$(BUILDTOOLS_PATH) product:$(notdir $(SWIFTLINT)) configuration:$(BUILDTOOLS_CONFIGURATION)

update-build-tools:
	swift package update --package-path $(BUILDTOOLS_PATH)
	@$(MAKE) prepare-build-tools

clean-build-tools:
	swift package reset --package-path $(BUILDTOOLS_PATH)

lint:
	$(SWIFTLINT) --fix --format
	$(SWIFTLINT)

generate-license:
	$(LICENSEPLIST) \
		--output-path $(SRCROOT)/iOS/Settings.bundle \
		--package-path $(WORKSPACE)/xcshareddata/swiftpm/Package.resolved \
		--fail-if-missing-license

generate-code:
	$(SWIFTGEN) --help || exit 0

check:
	$(FASTLANE) test \
		workspace:$(WORKSPACE) \
		scheme:"$(TARGET_NAME) ($(firstword $(PROJECT_NAMES)))"

report-coverage:
	bash -c "bash <(curl -s https://codecov.io/bash) -J $(TARGET_NAME) -c"

define DEPLOY
deploy-$(1):
	$(FASTLANE) deploy \
		workspace:$(WORKSPACE) \
		scheme:"$(TARGET_NAME) ($(1))"
endef

$(foreach project,$(PROJECT_NAMES),$(eval $(call DEPLOY,$(project))))

deploy-all: $(addprefix deploy-,$(PROJECT_NAMES))

current-version:
	$(FASTLANE) current_version \
		info_plist_path:$(firstword $(INFO_PLIST_FILE_PATHS))

bump-version-number:
ifdef VERSION_NUMBER
	$(FASTLANE) bump_version_number \
		info_plist_paths:"$(INFO_PLIST_FILE_PATHS)" \
		version_number:$(VERSION_NUMBER)
else
	$(FASTLANE) bump_version_number \
		info_plist_paths:"$(INFO_PLIST_FILE_PATHS)"
endif

bump-build-number:
ifdef BUILD_NUMBER
	$(FASTLANE) bump_build_number \
		info_plist_paths:"$(INFO_PLIST_FILE_PATHS)" \
		build_number:$(BUILD_NUMBER)
else
	$(FASTLANE) bump_build_number \
		info_plist_paths:"$(INFO_PLIST_FILE_PATHS)" \
		build_number:$(shell git rev-list HEAD --merges | wc -l | tr -d ' ')
endif

get-commit-hash-at-build-number:
	git rev-list HEAD --merges | tail -r | sed -n $(BUILD_NUMBER)p
