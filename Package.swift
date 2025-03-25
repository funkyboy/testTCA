// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyPackage",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "MyLibrary",
            type: .dynamic,
            targets: ["MyLibrary"]
        ),
    ],
    // dependencies: [
    //     .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.12.1"),
    // ],
    targets: [
        .target(
            name: "MyLibrary",
            // dependencies: [
            //     .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            // ],
            path: "Sources/MyLibrary"
        ),
    ]
)
