LICENSEPLIST = ./BuildTools/_LicensePlist/.build/release/license-plist
SWIFTLINT = ./BuildTools/_SwiftLint/.build/release/swiftlint
SWIFTGEN = ./BuildTools/_SwiftGen/.build/release/swiftgen

SRCROOT = ./App

bootstrap:
	rbenv install --skip-existing $(shell cat ./.ruby-version)
	rbenv exec gem install bundler
	bundle install
	$(MAKE) -j prepare-build-tools

prepare-build-tools:
	swift build --configuration release --package-path ./BuildTools/_LicensePlist --product license-plist
	swift build --configuration release --package-path ./BuildTools/_SwiftGen --product swiftgen
	swift build --configuration release --package-path ./BuildTools/_SwiftLint --product swiftlint

lint:
	$(SWIFTLINT) --fix --format
	$(SWIFTLINT)

generate-license:
	$(LICENSEPLIST) \
	--output-path ${SRCROOT}/iOS/Settings.bundle \
	--package-path ./ios-app-template.xcworkspace/xcshareddata/swiftpm/Package.resolved \
	--fail-if-missing-license

generate-code:
	$(SWIFTGEN) --help || exit 0
