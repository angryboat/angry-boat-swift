// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "angry-boat-swift",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .library(name: "AngryBoatUI", targets: ["AngryBoatUI"]),
        .library(name: "AngryBoatData", targets: ["AngryBoatData"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "600.0.1")
    ],
    targets: [
        .macro(name: "AngryBoatDataMacro", dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
        ]),
        .target(name: "AngryBoatUI"),
        .target(name: "AngryBoatData", dependencies: ["AngryBoatDataMacro"]),
        .testTarget(name: "AngryBoatUITests", dependencies: ["AngryBoatUI"]),
        .testTarget(name: "AngryBoatDataTests", dependencies: ["AngryBoatData", "AngryBoatDataMacro"]),
        .testTarget(name: "AngryBoatDataMacroTests", dependencies: [
            "AngryBoatDataMacro",
            .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax")
        ])
    ]
)
