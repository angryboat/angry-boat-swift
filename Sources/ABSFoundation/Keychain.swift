//
//  Keychain.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 2/25/25.
//

import Foundation
import Security

/// A namespace for keychain operations providing secure storage and retrieval of sensitive data.
public enum Keychain {
    /// Errors that can occur during keychain operations.
    public enum Error : Swift.Error, Equatable {
        /// A keychain operation failed with the given status code and optional message.
        case status(OSStatus, String?)
        /// An item with the same service and account already exists in the keychain.
        case duplicate
        /// The requested item was not found in the keychain.
        case notFound
        /// The data returned from the keychain was not in the expected format.
        case invalidTypeFormat
    }

    /// Creates a new keychain item.
    ///
    /// - Parameters:
    ///   - value: The data to store in the keychain.
    ///   - service: The service identifier for the keychain item.
    ///   - account: The account identifier for the keychain item.
    ///   - secClass: The keychain item class. Defaults to `kSecClassGenericPassword`.
    ///   - synchronizable: Whether the item should sync via iCloud Keychain. Defaults to `false`.
    /// - Throws: `Error.duplicate` if an item with the same service and account already exists,
    ///           or `Error.status` if the operation fails.
    public static func create(_ value: Data, service: String, account: String, secClass: CFString = kSecClassGenericPassword, synchronizable: Bool = false) throws(Error) {
        let query = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: secClass as AnyObject,
            kSecValueData as String: value as AnyObject,
            kSecAttrSynchronizable as String: synchronizable ? kCFBooleanTrue as AnyObject : kCFBooleanFalse as AnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
            break
        case errSecDuplicateItem:
            throw Error.duplicate
        default:
            let message = SecCopyErrorMessageString(status, nil) as String?
            throw Error.status(status, message)
        }
    }

    /// Updates an existing keychain item with new data.
    ///
    /// - Parameters:
    ///   - value: The new data to store in the keychain.
    ///   - service: The service identifier for the keychain item.
    ///   - account: The account identifier for the keychain item.
    ///   - secClass: The keychain item class. Defaults to `kSecClassGenericPassword`.
    ///   - synchronizable: Whether the item should sync via iCloud Keychain. Defaults to `false`.
    /// - Throws: `Error.status` if the operation fails.
    public static func update(_ value: Data, service: String, account: String, secClass: CFString = kSecClassGenericPassword, synchronizable: Bool = false) throws(Error) {
        let query = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String : secClass as AnyObject,
            kSecAttrSynchronizable as String: synchronizable ? kCFBooleanTrue as AnyObject : kCFBooleanFalse as AnyObject
        ]
        
        let attr = [kSecValueData as String: value as AnyObject]
        
        let status = SecItemUpdate(query as CFDictionary, attr as CFDictionary)
        
        if status == errSecSuccess {
            return
        }
        
        let message = SecCopyErrorMessageString(status, nil) as String?
        throw Error.status(status, message)
    }

    /// Reads data from an existing keychain item.
    ///
    /// - Parameters:
    ///   - service: The service identifier for the keychain item.
    ///   - account: The account identifier for the keychain item.
    ///   - secClass: The keychain item class. Defaults to `kSecClassGenericPassword`.
    /// - Returns: The data stored in the keychain item.
    /// - Throws: `Error.notFound` if the item doesn't exist,
    ///           `Error.invalidTypeFormat` if the data is not in the expected format,
    ///           or `Error.status` if the operation fails.
    public static func read(service: String, account: String, secClass: CFString = kSecClassGenericPassword) throws(Error) -> Data {
        let query = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: secClass as AnyObject,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true as AnyObject
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        switch status {
        case errSecSuccess:
            guard let data = item as? Data else {
                throw Error.invalidTypeFormat
            }
            return data
        case errSecItemNotFound:
            throw Error.notFound
        default:
            let message = SecCopyErrorMessageString(status, nil) as String?
            throw Error.status(status, message)
        }
    }

    /// Deletes a keychain item.
    ///
    /// - Parameters:
    ///   - service: The service identifier for the keychain item.
    ///   - account: The account identifier for the keychain item.
    ///   - secClass: The keychain item class. Defaults to `kSecClassGenericPassword`.
    /// - Throws: `Error.status` if the operation fails.
    public static func delete(service: String, account: String, secClass: CFString = kSecClassGenericPassword) throws(Error) {
        let query = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: secClass as AnyObject,
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        case errSecSuccess, errSecItemNotFound:
            break
        default:
            let message = SecCopyErrorMessageString(status, nil) as String?
            throw Error.status(status, message)
        }
    }

    /// Lists all account identifiers for a given service.
    ///
    /// - Parameters:
    ///   - service: The service identifier to query.
    ///   - secClass: The keychain item class. Defaults to `kSecClassGenericPassword`.
    /// - Returns: A set of account identifiers. Returns an empty set if no items are found.
    /// - Throws: `Error.invalidTypeFormat` if the data returned is not in the expected format,
    ///           or `Error.status` if the operation fails.
    public static func listAccounts(service: String, secClass: CFString = kSecClassGenericPassword) throws(Error) -> Set<String> {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecClass as String: secClass as AnyObject,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnAttributes as String: kCFBooleanTrue,
            kSecReturnRef as String: kCFBooleanTrue
        ]
        
        var items: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &items)
        
        switch status {
        case errSecSuccess:
            guard let queryResults = items as? [[String: AnyObject]] else {
                throw Error.invalidTypeFormat
            }
            var results = Set<String>()
            for item in queryResults {
                guard let account = item[kSecAttrAccount as String] as? String else {
                    continue
                }
                
                results.insert(account)
            }
            
            return results
        case errSecItemNotFound:
            return []
        default:
            let message = SecCopyErrorMessageString(status, nil) as String?
            throw Error.status(status, message)
        }
    }
}

/// An actor providing a service-scoped interface for keychain operations.
///
/// This actor wraps the static `Keychain` methods and provides a more convenient
/// interface when working with a single service identifier.
public actor KeychainService {
    /// The service identifier used for all keychain operations.
    public let service: String
    /// The keychain item class used for all operations.
    public let secClass: CFString

    /// Creates a new keychain service.
    ///
    /// - Parameters:
    ///   - service: The service identifier to use for all operations.
    ///   - secClass: The keychain item class. Defaults to `kSecClassGenericPassword`.
    public init(service: String, secClass: CFString = kSecClassGenericPassword) {
        self.service = service
        self.secClass = secClass
    }

    /// Lists all account identifiers for this service.
    ///
    /// - Returns: A set of account identifiers. Returns an empty set if no items are found.
    /// - Throws: `Keychain.Error.invalidTypeFormat` if the data returned is not in the expected format,
    ///           or `Keychain.Error.status` if the operation fails.
    public func accounts() throws(Keychain.Error) -> Set<String> {
        return try Keychain.listAccounts(service: service, secClass: secClass)
    }

    /// Retrieves data for the specified account.
    ///
    /// - Parameter account: The account identifier.
    /// - Returns: The data stored in the keychain, or `nil` if the item doesn't exist.
    /// - Throws: `Keychain.Error.invalidTypeFormat` if the data is not in the expected format,
    ///           or `Keychain.Error.status` if the operation fails.
    public func get(_ account: String) throws(Keychain.Error) -> Data? {
        do {
            return try Keychain.read(service: service, account: account, secClass: secClass)
        } catch Keychain.Error.notFound {
            return nil
        }
    }

    /// Stores data for the specified account, creating or updating as needed.
    ///
    /// If an item already exists for the account, it will be updated. Otherwise, a new item is created.
    ///
    /// - Parameters:
    ///   - data: The data to store.
    ///   - account: The account identifier.
    ///   - synchronizable: Whether the item should sync via iCloud Keychain. Defaults to `false`.
    /// - Throws: `Keychain.Error.status` if the operation fails.
    public func set(_ data: Data, _ account: String, synchronizable: Bool = false) throws(Keychain.Error) {
        do {
            _ = try Keychain.read(service: service, account: account, secClass: secClass)
            try Keychain.update(data, service: service, account: account, secClass: secClass)
        } catch Keychain.Error.notFound {
            try Keychain.create(data, service: service, account: account, secClass: secClass, synchronizable: synchronizable)
        }
    }

    /// Deletes the keychain item for the specified account.
    ///
    /// - Parameter account: The account identifier.
    /// - Throws: `Keychain.Error.status` if the operation fails.
    public func delete(_ account: String) throws(Keychain.Error) {
        try Keychain.delete(service: service, account: account, secClass: secClass)
    }
}
