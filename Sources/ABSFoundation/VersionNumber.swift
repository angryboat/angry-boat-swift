//
//  VersionNumber.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 9/26/25.
//

/// A semantic version number with major, minor, and patch components.
///
/// VersionNumber follows semantic versioning principles where:
/// - Major version indicates breaking changes
/// - Minor version indicates new features with backward compatibility
/// - Patch version indicates bug fixes
public struct VersionNumber : Sendable, Hashable, Comparable, Equatable {
    /// Errors that can occur when parsing version strings.
    public enum ParseError : Swift.Error {
        /// Thrown when a version string cannot be parsed.
        /// - Parameters:
        ///   - String: The original version string that failed to parse
        ///   - String: A descriptive error message
        case malformedVersionString(String, String)
    }
    
    /// Compares two version numbers for ordering.
    ///
    /// Versions are compared by major, then minor, then patch components.
    /// - Parameters:
    ///   - lhs: The left-hand side version
    ///   - rhs: The right-hand side version
    /// - Returns: `true` if the left version is less than the right version
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else {
            return lhs.patch < rhs.patch
        }
    }
    
    /// The major version component.
    public let major: Int

    /// The minor version component.
    public let minor: Int

    /// The patch version component.
    public let patch: Int
    
    /// The string representation of the version number in "major.minor.patch" format.
    public var string: String {
        "\(major).\(minor).\(patch)"
    }
    
    /// Creates a version number with the specified components.
    /// - Parameters:
    ///   - major: The major version component
    ///   - minor: The minor version component
    ///   - patch: The patch version component
    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    /// Creates a version number by parsing a string.
    ///
    /// Supports the following formats:
    /// - "1" (major only, minor and patch default to 0)
    /// - "1.2" (major.minor, patch defaults to 0)
    /// - "1.2.3" (major.minor.patch)
    ///
    /// - Parameter string: The version string to parse
    /// - Throws: `ParseError.malformedVersionString` if the string cannot be parsed
    public init(string: String) throws(ParseError) {
        let components = string.split(separator: ".").map { String($0) }
        
        switch components.count {
        case 1:
            guard let major = Int(components[0]) else {
                throw ParseError.malformedVersionString(string, "The major number must be an integer")
            }
            
            self.major = major
            self.minor = 0
            self.patch = 0
        case 2:
            guard let major = Int(components[0]) else {
                throw ParseError.malformedVersionString(string, "The major number must be an integer")
            }
            guard let minor = Int(components[1]) else {
                throw ParseError.malformedVersionString(string, "The minor number must be an integer")
            }
            
            self.major = major
            self.minor = minor
            self.patch = 0
        case 3:
            guard let major = Int(components[0]) else {
                throw ParseError.malformedVersionString(string, "The major number must be an integer")
            }
            guard let minor = Int(components[1]) else {
                throw ParseError.malformedVersionString(string, "The minor number must be an integer")
            }
            guard let patch = Int(components[2]) else {
                throw ParseError.malformedVersionString(string, "The patch number must be an integer")
            }
            
            self.major = major
            self.minor = minor
            self.patch = patch
        default:
            throw ParseError.malformedVersionString(string, "Expected 1, 2, or 3 components in the version string (e.g. '1.0.0', '2', '1.0')")
        }
    }
}
