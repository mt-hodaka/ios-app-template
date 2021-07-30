// swift-tools-version:5.3
// swiftlint:disable file_length line_length

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
            ]),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
            ]),
    ]
)
