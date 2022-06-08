// swift-tools-version: 5.6
// swiftlint:disable file_length line_length

import PackageDescription

let package = Package(
    name: "_SwiftGen",
    platforms: [
        .macOS(.v11),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftGen/SwiftGen.git", from: "6.4.0"),
    ]
)
