// swift-tools-version:5.3
// swiftlint:disable file_length line_length

import PackageDescription

let package = Package(
    name: "_LicensePlist",
    platforms: [
        .macOS(.v11),
    ],
    dependencies: [
        .package(url: "https://github.com/mono0926/LicensePlist.git", .upToNextMajor(from: "3.13.0")),
    ],
    targets: [
        .target(name: "_LicensePlist", path: ""),
    ]
)
