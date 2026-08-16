// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "VentilationAdvisor",
    products: [
        .library(
            name: "VentilationAdvisor",
            targets: ["VentilationAdvisor"]
        )
    ],
    targets: [
        .target(
            name: "VentilationAdvisor"
        ),
        .testTarget(
            name: "VentilationAdvisorTests",
            dependencies: ["VentilationAdvisor"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
