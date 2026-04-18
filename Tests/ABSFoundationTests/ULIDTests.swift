//
//  ULIDTests.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 4/18/26.
//

import Testing
import Foundation
import ABSFoundation

@Suite("ULID")
struct ULIDTests {

    // MARK: - Generation

    @Test
    func `create with no provided arguments`() {
        #expect(throws: Never.self) {
            _ = try ULID()
        }
    }

    @Test
    func `create with explicit timestamp`() {
        #expect(throws: Never.self) {
            _ = try ULID(Date(timeIntervalSince1970: 1_000_000))
        }
    }

    // MARK: - Encoding

    @Test
    func `ulidString is 26 characters`() {
        let ulid = ULID()
        #expect(ulid.ulidString.count == 26)
    }

    @Test
    func `ulidString contains only valid crockford characters`() {
        let valid = Set("0123456789ABCDEFGHJKMNPQRSTVWXYZ")
        let ulid = ULID()
        for char in ulid.ulidString {
            #expect(valid.contains(char), "unexpected character: \(char)")
        }
    }

    @Test
    func `ulidString first character is at most 7`() {
        let ulid = ULID()
        let first = ulid.ulidString.first!
        #expect("01234567".contains(first))
    }

    @Test
    func `description matches ulidString`() {
        let ulid = ULID()
        #expect(ulid.description == ulid.ulidString)
    }

    // MARK: - Decoding

    @Test(arguments: [
        "01KPGR1TJKWP32J4AK9YAQTCFH",
        "7ZZZZZZZZZZZZZZZZZZZZZZZZZ",
        "0000000000000000000000000",  // invalid length (25)
    ].prefix(2))
    func `parsing valid strings`(_ string: String) {
        #expect(throws: Never.self) {
            _ = try ULID(string: string)
        }
    }

    @Test
    func `re-encoding a parsed ulid produces the original string`() throws {
        let string = "01KPGR1TJKWP32J4AK9YAQTCFH"
        let ulid = try ULID(string: string)
        #expect(ulid.ulidString == string)
    }

    @Test
    func `parsing is case insensitive`() throws {
        let lower = "01kpgr1tjkwp32j4ak9yaqtcfh"
        let upper = "01KPGR1TJKWP32J4AK9YAQTCFH"
        let a = try ULID(string: lower)
        let b = try ULID(string: upper)
        #expect(a == b)
    }

    @Test
    func `max valid ulid parses without overflow`() {
        #expect(throws: Never.self) {
            _ = try ULID(string: "7ZZZZZZZZZZZZZZZZZZZZZZZZZ")
        }
    }

    // MARK: - Round-trip

    @Test
    func `string round-trip preserves value`() throws {
        let original = ULID()
        let decoded = try ULID(string: original.ulidString)
        #expect(original == decoded)
    }

    @Test
    func `lossless string convertible round-trip`() {
        let original = ULID()
        let decoded = ULID(original.ulidString)
        #expect(decoded != nil)
        #expect(original == decoded)
    }

    // MARK: - Codable

    @Test
    func `codable json round-trip`() throws {
        let original = ULID()
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ULID.self, from: data)
        #expect(original == decoded)
    }

    @Test
    func `encodes as string in json`() throws {
        let ulid = try ULID(string: "01KPGR1TJKWP32J4AK9YAQTCFH")
        let data = try JSONEncoder().encode(ulid)
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
        #expect(json == "01KPGR1TJKWP32J4AK9YAQTCFH")
    }

    // MARK: - Comparable

    @Test
    func `earlier timestamp compares less than later`() throws {
        let earlier = try ULID(Date(timeIntervalSince1970: 1_000_000))
        let later = try ULID(Date(timeIntervalSince1970: 2_000_000))
        #expect(earlier < later)
    }

    @Test
    func `ulids with same millisecond are ordered by randomness`() throws {
        let ts = Date(timeIntervalSinceReferenceDate: 1_000_000)
        var ulids: [ULID] = []
        for _ in 0..<10 {
            ulids.append(try ULID(ts))
        }
        let sorted = ulids.sorted()
        #expect(sorted == ulids.sorted())
    }

    // MARK: - Error cases

    @Test(arguments: [
        "",
        "01KPGR1TJKWP32J4AK9YAQTCF",   // 25 chars
        "01KPGR1TJKWP32J4AK9YAQTCFHH",  // 27 chars
    ])
    func `invalid length throws`(_ string: String) {
        #expect(throws: ULIDError.self) {
            _ = try ULID(string: string)
        }
    }

    @Test(arguments: [
        "01KPGR1TJKWP32J4AK9YAQTCFI",  // I
        "01KPGR1TJKWP32J4AK9YAQTCFL",  // L
        "01KPGR1TJKWP32J4AK9YAQTCFO",  // O
        "01KPGR1TJKWP32J4AK9YAQTCFU",  // U
        "01KPGR1TJKWP32J4AK9YAQTCF!",  // symbol
    ])
    func `invalid characters throw`(_ string: String) {
        #expect(throws: ULIDError.self) {
            _ = try ULID(string: string)
        }
    }

    @Test(arguments: [
        "8ZZZZZZZZZZZZZZZZZZZZZZZZZ",
        "FZZZZZZZZZZZZZZZZZZZZZZZZZZ",  // invalid length too, but overflow check fires first after decoding
    ].prefix(1))
    func `overflow strings throw`(_ string: String) {
        #expect(throws: ULIDError.self) {
            _ = try ULID(string: string)
        }
    }
}
