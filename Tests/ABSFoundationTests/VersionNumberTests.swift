//
//  VersionNumberTests.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 9/26/25.
//

import Testing

@testable
import ABSFoundation

@Test(arguments: [
    ("1", (1, 0, 0)),
    ("1.0", (1, 0, 0)),
    ("1.1", (1, 1, 0)),
    ("1.1.5", (1, 1, 5)),
])
func createValidVersionNumber(_ input: (String, (Int, Int, Int))) throws {
    let (string, expected) = input
    let version = try VersionNumber(string: string)
    
    #expect(version.major == expected.0)
    #expect(version.minor == expected.1)
    #expect(version.patch == expected.2)
}

@Test(arguments: [
    ("2025.80.2094", "2025.79.1453", false),
    ("2025.80.2094", "2025.80.2094", false),
    ("2025.80.2090", "2025.80.2094", true),
    ("2025.72.5000", "2025.79.1453", true),
    ("2023.100.5000", "2025.79.1453", true),
])
func compareVersionNumber(_ input: (String, String, Bool)) throws {
    let (lStr, rStr, exepected) = input

    let lhs = try VersionNumber(string: lStr)
    let rhs = try VersionNumber(string: rStr)

    #expect(exepected == (lhs < rhs), "\(lStr) < \(rStr) != \(exepected)")
}

@Test(arguments: [
    ("1.0.0", "1.0.0", true),
    ("2.5.8", "2.5.8", true),
    ("1.0.0", "1.0.1", false),
    ("1.0.0", "1.1.0", false),
    ("1.0.0", "2.0.0", false),
    ("1", "1.0.0", true),
    ("1.5", "1.5.0", true),
])
func equalVersionNumber(_ input: (String, String, Bool)) throws {
    let (lStr, rStr, expected) = input

    let lhs = try VersionNumber(string: lStr)
    let rhs = try VersionNumber(string: rStr)

    #expect(expected == (lhs == rhs), "\(lStr) == \(rStr) != \(expected)")
    #expect(expected != (lhs != rhs), "\(lStr) != \(rStr) should be \(!expected)")
}
