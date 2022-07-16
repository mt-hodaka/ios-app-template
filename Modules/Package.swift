// swift-tools-version: 5.6
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
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "9.3.0"),
    ],
    targets: [
        // MARK: - AppFeature
        .target(
            name: "AppFeature",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
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
    ]
)
