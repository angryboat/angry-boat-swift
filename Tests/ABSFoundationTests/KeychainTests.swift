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
        try? Keychain.delete(service: service, account: "foo-1")
        try? Keychain.delete(service: service, account: "foo-2")
        try? Keychain.delete(service: service, account: "bar-1")
        
        try Keychain.create("Foo-1".data(using: .utf8)!, service: service, account: "foo-1")
        try Keychain.create("Foo-2".data(using: .utf8)!, service: service, account: "foo-2")
        try Keychain.create("Bar-1".data(using: .utf8)!, service: service, account: "bar-1")
        
        let accounts = try Keychain.listAccounts(service: service)
        #expect(accounts.contains { $0 == "foo-1" } == true)
        #expect(accounts.contains { $0 == "foo-2" } == true)
        #expect(accounts.contains { $0 == "bar-1" } == true)
    }
}
