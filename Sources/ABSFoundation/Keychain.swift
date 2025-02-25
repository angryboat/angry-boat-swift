//
//  Keychain.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 2/25/25.
//

import Foundation
import Security

public enum Keychain {
    public enum Error : Swift.Error {
        case status(OSStatus, String?)
        case duplicate
        case notFound
        case invalidTypeFormat
    }
    
    public static func create(_ value: Data, service: String, account: String, secClass: CFString = kSecClassGenericPassword, synchronizable: Bool = false) throws {
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
    
    public static func update(_ value: Data, service: String, account: String, secClass: CFString = kSecClassGenericPassword, synchronizable: Bool = false) throws {
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
    
    public static func read(service: String, account: String, secClass: CFString = kSecClassGenericPassword) throws -> Data {
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
    
    public static func delete(service: String, account: String, secClass: CFString = kSecClassGenericPassword) throws {
        let query = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: secClass as AnyObject,
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            return
        }
        
        let message = SecCopyErrorMessageString(status, nil) as String?
        throw Error.status(status, message)
    }
}
