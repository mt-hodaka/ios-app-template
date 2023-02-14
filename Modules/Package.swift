// swift-tools-version: 5.6
// swiftlint:disable file_length line_length

import PackageDescription

let package = Package(
    name: "Modules",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
    ],
    dependencies: [
        // MARK: Dependencies
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.5.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.4"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "0.0.4"),

        // MARK: Plugins
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
    ],
    targets: [
        // MARK: AppFeature

        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                "UIComponents",
                "Core",
            ],
            linkerSettings: [
                // https://firebase.google.com/docs/ios/installation-methods#integrate-manually
                .unsafeFlags(["-ObjC"]),
            ]),

        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature",
            ]),

        // MARK: UIComponents

        .target(
            name: "UIComponents",
            dependencies: [
                "Resources",
            ]),

        // MARK: Resources

        .target(
            name: "Resources",
            dependencies: [
            ],
            exclude: [
                "swiftgen.yml",
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
            ]),

        // MARK: Core

        .target(
            name: "Core",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]),

        .testTarget(
            name: "CoreTests",
            dependencies: [
                "Core",
            ]),
    ]
)
