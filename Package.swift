// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobileOrder",
    platforms: [ .macOS(.v10_15), .iOS(.v13) ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MobileOrder",
            targets: ["MobileOrder"]),
    ],
    dependencies: [
        .package(path: "../MoneyAndExchangeRates"),
        .package(path: "../MobileLegacyOrder"),
        .package(path: "../MobileDownload")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MobileOrder",
            dependencies: ["MoneyAndExchangeRates", "MobileLegacyOrder", "MobileDownload"]),
        .testTarget(
            name: "MobileOrderTests",
            dependencies: ["MobileOrder", "MoneyAndExchangeRates", "MobileLegacyOrder", "MobileDownload"]),
    ]
)
