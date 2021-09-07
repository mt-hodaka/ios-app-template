export FL_XCODE_VERSION = $(shell cat ./.xcode-version)
ifdef CI
	export FASTLANE_HIDE_TIMESTAMP = true
	export CLONED_SOURCE_PACKAGES_PATH = ~/Library/Caches/SourcePackages
endif

FASTLANE = bundle exec fastlane
LICENSEPLIST = ./BuildTools/_LicensePlist/.build/release/license-plist
SWIFTLINT = ./BuildTools/_SwiftLint/.build/release/swiftlint
SWIFTGEN = ./BuildTools/_SwiftGen/.build/release/swiftgen

SRCROOT = ./App
TARGET_NAME = ios-app-template
WORKSPACE = ./$(TARGET_NAME).xcworkspace
PROJECTS = $(wildcard $(SRCROOT)/*.xcodeproj)
PROJECT_NAMES = $(basename $(notdir $(PROJECTS)))
INFO_PLIST_FILE_PATHS = $(patsubst %,$(SRCROOT)/iOS/%/Info.plist,$(PROJECT_NAMES))

bootstrap: prepare-gems prepare-build-tools

prepare-gems:
ifndef CI
	rbenv install --skip-existing $(shell cat ./.ruby-version)
	rbenv exec gem install bundler
endif
	bundle install

prepare-build-tools:
	$(FASTLANE) prepare_build_tools \
		binary_paths:"$(LICENSEPLIST) $(SWIFTLINT) $(SWIFTGEN)"

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
	$(FASTLANE) \
		info_plist_paths:"$(INFO_PLIST_FILE_PATHS)" \
		bump_build_number build_number:$(BUILD_NUMBER)
else
	$(FASTLANE) bump_build_number \
		info_plist_paths:"$(INFO_PLIST_FILE_PATHS)" \
		build_number:$(shell git rev-list HEAD --merges | wc -l | tr -d ' ')
endif

get-commit-hash-at-build-number:
	git rev-list HEAD --merges | tail -r | sed -n $(BUILD_NUMBER)p
