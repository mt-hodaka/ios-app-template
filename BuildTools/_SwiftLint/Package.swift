// swift-tools-version:5.3
// swiftlint:disable file_length line_length

import PackageDescription

let package = Package(
    name: "_SwiftLint",
    platforms: [
        .macOS(.v11),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.43.1")),
    ],
    targets: [
        .target(name: "_SwiftLint", path: ""),
    ]
)
