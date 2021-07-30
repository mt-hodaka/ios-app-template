// swift-tools-version:5.3
// swiftlint:disable file_length line_length

import PackageDescription

let package = Package(
    name: "_SwiftGen",
    platforms: [
        .macOS(.v11),
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftGen/SwiftGen.git", .upToNextMajor(from: "6.4.0")),
    ],
    targets: [
        .target(name: "_SwiftGen", path: ""),
    ]
)
