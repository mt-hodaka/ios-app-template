// swift-tools-version: 5.6
// swiftlint:disable file_length line_length

import PackageDescription

var package = Package(
    name: "Modules",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "9.4.1"),
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
    ]
)

// MARK: - Plugins

package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.0"),
])
