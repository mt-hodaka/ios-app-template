// swift-tools-version: 5.6
// swiftlint:disable file_length line_length

import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [
        .macOS(.v11),
    ],
    dependencies: [
        .package(url: "https://github.com/mono0926/LicensePlist.git", from: "3.13.0"),
        .package(url: "https://github.com/SwiftGen/SwiftGen.git", from: "6.4.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.47.1"),
    ]
)
