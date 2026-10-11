// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "TOMLCompatibility",
    platforms: [.macOS(.v10_15)],
    dependencies: [.package(path: "../..")],
    targets: [
        .executableTarget(
            name: "TOMLCompatibility",
            dependencies: [.product(name: "TOML", package: "swift-toml")]
        )
    ]
)
