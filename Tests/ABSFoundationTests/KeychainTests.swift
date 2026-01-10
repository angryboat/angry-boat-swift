//
//  KeychainTests.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 2/25/25.
//

import Foundation
import Testing

@testable import ABSFoundation

struct KeychainTests {
    @Test(arguments: ["ABS-Testing"])
    func read(_ service: String) throws {
        let originalData = UUID().uuidString.data(using: .utf8)!
        
        try Keychain.create(originalData, service: service, account: #function)
        
        let readData = try Keychain.read(service: service, account: #function)
        
        try Keychain.delete(service: service, account: #function)
        
        #expect(readData == originalData)
    }
    
    @Test(arguments: ["ABS-Testing"])
    func create(_ service: String) throws {
        let data = UUID().uuidString.data(using: .utf8)!
        
        try Keychain.create(data, service: service, account: #function)
        try Keychain.delete(service: service, account: #function)
    }
    
    @Test(arguments: ["ABS-Testing"])
    func update(_ service: String) throws {
        let originalData = UUID().uuidString.data(using: .utf8)!
        
        try Keychain.create(originalData, service: service, account: #function)
        
        let newData = UUID().uuidString.data(using: .utf8)!
        
        try Keychain.update(newData, service: service, account: #function)
        
        let readData = try Keychain.read(service: service, account: #function)
        
        #expect(readData == newData)
        
        try Keychain.delete(service: service, account: #function)
    }
    
    @Test(arguments: ["ABS-Testing-2"])
    func listAccounts(_ service: String) throws {
        try Keychain.delete(service: service, account: "foo-1")
        try Keychain.delete(service: service, account: "foo-2")
        try Keychain.delete(service: service, account: "bar-1")
        
        try Keychain.create("Foo-1".data(using: .utf8)!, service: service, account: "foo-1")
        try Keychain.create("Foo-2".data(using: .utf8)!, service: service, account: "foo-2")
        try Keychain.create("Bar-1".data(using: .utf8)!, service: service, account: "bar-1")
        
        let accounts = try Keychain.listAccounts(service: service)
        #expect(accounts.contains { $0 == "foo-1" } == true)
        #expect(accounts.contains { $0 == "foo-2" } == true)
        #expect(accounts.contains { $0 == "bar-1" } == true)
    }
    
    @Test(arguments: ["ABS-Testing-3"])
    func `delete will delete an item`(_ service: String) throws {
        let account = UUID().uuidString
        try? Keychain.create(UUID().uuidString.data(using: .utf8)!, service: service, account: account)
        
        #expect(throws: Never.self) {
            try Keychain.delete(service: service, account: account)
        }
        
        #expect(throws: Keychain.Error.notFound) {
            try Keychain.read(service: service, account: account)
        }
    }
    
    @Test
    func `delete does not throw an error if the item does not exist`() {
        #expect(throws: Never.self) {
            try Keychain.delete(service: "testing-missing-key", account: UUID().uuidString)
        }
    }
}

struct KeychainServiceTests {
    @Test(arguments: ["ABS-Testing-Service"])
    func getReturnsNilForNonExistentAccount(_ service: String) async throws {
        let keychainService = KeychainService(service: service)

        let data = try await keychainService.get("non-existent-account")

        #expect(data == nil)
    }

    @Test(arguments: ["ABS-Testing-Service"])
    func setAndGet(_ service: String) async throws {
        let keychainService = KeychainService(service: service)
        let originalData = UUID().uuidString.data(using: .utf8)!

        try await keychainService.set(originalData, #function)

        let readData = try await keychainService.get(#function)

        try await keychainService.delete(#function)

        #expect(readData == originalData)
    }

    @Test(arguments: ["ABS-Testing-Service"])
    func setUpdatesExistingItem(_ service: String) async throws {
        let keychainService = KeychainService(service: service)
        let originalData = UUID().uuidString.data(using: .utf8)!

        try await keychainService.set(originalData, #function)

        let newData = UUID().uuidString.data(using: .utf8)!
        try await keychainService.set(newData, #function)

        let readData = try await keychainService.get(#function)

        #expect(readData == newData)

        try await keychainService.delete(#function)
    }

    @Test(arguments: ["ABS-Testing-Service"])
    func delete(_ service: String) async throws {
        let keychainService = KeychainService(service: service)
        let data = UUID().uuidString.data(using: .utf8)!

        try await keychainService.set(data, #function)
        try await keychainService.delete(#function)

        let readData = try await keychainService.get(#function)
        #expect(readData == nil)
    }

    @Test(arguments: ["ABS-Testing-Service-List"])
    func accounts(_ service: String) async throws {
        let keychainService = KeychainService(service: service)

        try await keychainService.delete("account-1")
        try await keychainService.delete("account-2")
        try await keychainService.delete("account-3")

        try await keychainService.set("Data-1".data(using: .utf8)!, "account-1")
        try await keychainService.set("Data-2".data(using: .utf8)!, "account-2")
        try await keychainService.set("Data-3".data(using: .utf8)!, "account-3")

        let accounts = try await keychainService.accounts()
        #expect(accounts.contains { $0 == "account-1" } == true)
        #expect(accounts.contains { $0 == "account-2" } == true)
        #expect(accounts.contains { $0 == "account-3" } == true)

        try await keychainService.delete("account-1")
        try await keychainService.delete("account-2")
        try await keychainService.delete("account-3")
    }
}
