// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "TOML",
    platforms: [
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "TOML",
            targets: ["TOML"]
        )
    ],
    targets: [
        .target(
            name: "CTomlPlusPlus",
            path: "Sources/CTomlPlusPlus",
            sources: ["ctoml.cpp"],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath(".")
            ]
        ),
        .target(
            name: "TOML",
            dependencies: ["CTomlPlusPlus"]
        ),
    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx17
)
