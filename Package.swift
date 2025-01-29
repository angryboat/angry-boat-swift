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
        .library(name: "AngryBoatData", targets: ["AngryBoatData"]),
        .library(name: "ABSFoundation", targets: ["ABSFoundation"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "600.0.1")
    ],
    targets: [
        .macro(name: "ABSMacro", dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
        ]),
        .target(name: "AngryBoatUI", dependencies: ["ABSFoundation"]),
        .target(name: "AngryBoatData", dependencies: ["ABSMacro"]),
        .target(name: "ABSFoundation", dependencies: ["ABSMacro"]),
        .testTarget(name: "AngryBoatUITests", dependencies: ["AngryBoatUI"]),
        .testTarget(name: "AngryBoatDataTests", dependencies: ["AngryBoatData"]),
        .testTarget(name: "ABSFoundationTests", dependencies: ["ABSFoundation"]),
        .testTarget(name: "ABSMacroTests", dependencies: [
            "ABSMacro",
            .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax")
        ])
    ]
)
