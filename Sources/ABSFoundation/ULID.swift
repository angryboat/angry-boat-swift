//
//  ULID.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 4/18/26.
//

import Foundation
import Security

/// A Universally Unique Lexicographically Sortable Identifier.
///
/// A 128-bit value composed of a 48-bit millisecond timestamp and 80 bits of cryptographically
/// secure randomness, encoded as a 26-character Crockford Base32 string. ULIDs are sortable by
/// creation time and safe to use as database primary keys.
public struct ULID: Sendable {
    private static let alphabet: [Character] = Array("0123456789ABCDEFGHJKMNPQRSTVWXYZ")

    /// Milliseconds since the Unix epoch.
    public let milliseconds: UInt64

    /// The timestamp component, derived from ``milliseconds``.
    public var timestamp: Date {
        Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000.0)
    }

    // 80 bits of randomness stored as high 16 bits + low 64 bits
    let _randomHigh: UInt16
    let _randomLow: UInt64

    // MARK: - Init

    /// Creates a new ULID with the current time. Falls back to `Swift.random` if secure randomness is unavailable.
    public init() {
        self.milliseconds = UInt64(max(0, Date.now.timeIntervalSince1970 * 1000))
        if let (high, low) = try? Self._generateRandom() {
            _randomHigh = high
            _randomLow = low
        } else {
            _randomHigh = UInt16.random(in: 0...UInt16.max)
            _randomLow = UInt64.random(in: 0...UInt64.max)
        }
    }

    /// Creates a new ULID with the given timestamp and cryptographically secure random bits.
    /// - Throws: ``ULIDError/randomGeneratorError(_:_:)`` if the system RNG fails.
    public init(_ timestamp: Date = .now) throws(ULIDError) {
        self.milliseconds = UInt64(max(0, timestamp.timeIntervalSince1970 * 1000))
        (_randomHigh, _randomLow) = try Self._generateRandom()
    }

    /// Parses a ULID from its 26-character Crockford Base32 string representation. Case-insensitive.
    /// - Throws: ``ULIDError`` if the string is the wrong length, contains invalid characters, or overflows.
    public init(string: String) throws(ULIDError) {
        let upper = string.uppercased()
        guard upper.count == 26 else {
            throw ULIDError.invalidLength(upper.count)
        }

        var values = [UInt8]()
        values.reserveCapacity(26)
        for char in upper {
            guard let v = Self._decodeChar(char) else {
                throw ULIDError.invalidCharacter(char)
            }
            values.append(v)
        }

        // First char must be ≤ 7: max ULID is 7ZZZZZZZZZZZZZZZZZZZZZZZZZ
        guard values[0] <= 7 else {
            throw ULIDError.overflow
        }

        // Chars[0..9] → 48-bit millisecond timestamp
        var ms: UInt64 = 0
        for i in 0..<10 {
            ms = (ms << 5) | UInt64(values[i])
        }

        // Chars[10..12] → bits [15:1] of randomHigh
        // Chars[13]     → bit  [0]    of randomHigh + bits [63:60] of randomLow
        // Chars[14..25] → bits [59:0] of randomLow
        let high = (UInt16(values[10]) << 11)
                 | (UInt16(values[11]) << 6)
                 | (UInt16(values[12]) << 1)
                 | UInt16(values[13] >> 4)

        var low = UInt64(values[13] & 0xF) << 60
        for i in 14..<26 {
            low |= UInt64(values[i]) << UInt64((25 - i) * 5)
        }

        self.milliseconds = ms
        _randomHigh = high
        _randomLow = low
    }

    // MARK: - String

    /// The canonical 26-character Crockford Base32 string representation.
    public var ulidString: String {
        let ms = milliseconds
        let alpha = Self.alphabet
        var chars = [Character](repeating: "0", count: 26)

        // Timestamp: 10 chars, MSB first
        var ts = ms
        for i in stride(from: 9, through: 0, by: -1) {
            chars[i] = alpha[Int(ts & 0x1F)]
            ts >>= 5
        }

        // Randomness: 16 chars
        chars[10] = alpha[Int((_randomHigh >> 11) & 0x1F)]
        chars[11] = alpha[Int((_randomHigh >> 6) & 0x1F)]
        chars[12] = alpha[Int((_randomHigh >> 1) & 0x1F)]
        chars[13] = alpha[Int((UInt16(_randomHigh & 0x1) << 4) | UInt16(_randomLow >> 60))]
        chars[14] = alpha[Int((_randomLow >> 55) & 0x1F)]
        chars[15] = alpha[Int((_randomLow >> 50) & 0x1F)]
        chars[16] = alpha[Int((_randomLow >> 45) & 0x1F)]
        chars[17] = alpha[Int((_randomLow >> 40) & 0x1F)]
        chars[18] = alpha[Int((_randomLow >> 35) & 0x1F)]
        chars[19] = alpha[Int((_randomLow >> 30) & 0x1F)]
        chars[20] = alpha[Int((_randomLow >> 25) & 0x1F)]
        chars[21] = alpha[Int((_randomLow >> 20) & 0x1F)]
        chars[22] = alpha[Int((_randomLow >> 15) & 0x1F)]
        chars[23] = alpha[Int((_randomLow >> 10) & 0x1F)]
        chars[24] = alpha[Int((_randomLow >> 5) & 0x1F)]
        chars[25] = alpha[Int(_randomLow & 0x1F)]

        return String(chars)
    }

    // MARK: - Private

    private static func _generateRandom() throws(ULIDError) -> (UInt16, UInt64) {
        var bytes = [UInt8](repeating: 0, count: 10)
        let status = SecRandomCopyBytes(kSecRandomDefault, 10, &bytes)
        guard status == errSecSuccess else {
            let message = SecCopyErrorMessageString(status, nil) as? String ?? "Unknown Error"
            throw ULIDError.randomGeneratorError(message, status)
        }
        let high = (UInt16(bytes[0]) << 8) | UInt16(bytes[1])
        let low = (UInt64(bytes[2]) << 56)
                | (UInt64(bytes[3]) << 48)
                | (UInt64(bytes[4]) << 40)
                | (UInt64(bytes[5]) << 32)
                | (UInt64(bytes[6]) << 24)
                | (UInt64(bytes[7]) << 16)
                | (UInt64(bytes[8]) << 8)
                |  UInt64(bytes[9])
        return (high, low)
    }

    private static func _decodeChar(_ char: Character) -> UInt8? {
        switch char {
        case "0": return 0
        case "1": return 1
        case "2": return 2
        case "3": return 3
        case "4": return 4
        case "5": return 5
        case "6": return 6
        case "7": return 7
        case "8": return 8
        case "9": return 9
        case "A": return 10
        case "B": return 11
        case "C": return 12
        case "D": return 13
        case "E": return 14
        case "F": return 15
        case "G": return 16
        case "H": return 17
        case "J": return 18
        case "K": return 19
        case "M": return 20
        case "N": return 21
        case "P": return 22
        case "Q": return 23
        case "R": return 24
        case "S": return 25
        case "T": return 26
        case "V": return 27
        case "W": return 28
        case "X": return 29
        case "Y": return 30
        case "Z": return 31
        default: return nil
        }
    }
}

extension ULID: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.milliseconds == rhs.milliseconds
            && lhs._randomHigh == rhs._randomHigh
            && lhs._randomLow == rhs._randomLow
    }
}

extension ULID: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(milliseconds)
        hasher.combine(_randomHigh)
        hasher.combine(_randomLow)
    }
}

extension ULID: Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        if lhs.milliseconds != rhs.milliseconds { return lhs.milliseconds < rhs.milliseconds }
        if lhs._randomHigh != rhs._randomHigh { return lhs._randomHigh < rhs._randomHigh }
        return lhs._randomLow < rhs._randomLow
    }
}

extension ULID: CustomStringConvertible {
    public var description: String { ulidString }
}

extension ULID: LosslessStringConvertible {
    public init?(_ description: String) {
        try? self.init(string: description)
    }
}

extension ULID: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(ulidString)
    }
}

extension ULID: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let ulidString = try container.decode(String.self)
        self = try .init(string: ulidString)
    }
}

/// Errors thrown during ULID generation or parsing.
public enum ULIDError: Error {
    /// The system random number generator returned an error.
    case randomGeneratorError(String, OSStatus)
    /// The input string is not 26 characters.
    case invalidLength(Int)
    /// The input string contains a character outside the Crockford Base32 alphabet.
    case invalidCharacter(Character)
    /// The encoded value exceeds the maximum valid ULID (`7ZZZZZZZZZZZZZZZZZZZZZZZZZ`).
    case overflow
}
