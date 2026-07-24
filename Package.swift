// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ColorThemeKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "ColorThemeKit", targets: ["ColorThemeKit"])
    ],
    targets: [
        .target(name: "ColorThemeKit"),
        .testTarget(name: "ColorThemeKitTests", dependencies: ["ColorThemeKit"])
    ]
)
