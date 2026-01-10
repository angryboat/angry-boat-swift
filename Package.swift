// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "angry-boat-swift",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
    ],
    products: [
        .library(name: "AngryBoatUI", targets: ["AngryBoatUI"]),
        .library(name: "AngryBoatData", targets: ["AngryBoatData"]),
        .library(name: "ABSFoundation", targets: ["ABSFoundation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "602.0.0")
    ],
    targets: [
        .macro(
            name: "ABSMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]),
        .target(name: "AngryBoatUI", dependencies: ["ABSFoundation"]),
        .target(name: "AngryBoatData", dependencies: ["ABSMacro"]),
        .target(name: "ABSFoundation", dependencies: ["ABSMacro"]),
        .testTarget(name: "AngryBoatUITests", dependencies: ["AngryBoatUI"]),
        .testTarget(name: "AngryBoatDataTests", dependencies: ["AngryBoatData"]),
        .testTarget(name: "ABSFoundationTests", dependencies: ["ABSFoundation"]),
        .testTarget(
            name: "ABSMacroTests",
            dependencies: [
                "ABSMacro",
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
            ]),
    ]
)
