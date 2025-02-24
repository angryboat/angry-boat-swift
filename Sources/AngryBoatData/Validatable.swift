//
//  Validatable.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 2/24/25.
//

public protocol Validatable {
    func validates(context: inout ValidationContext<Self>)
}

extension Validatable {
    public func validate() throws {
        var context = ValidationContext<Self>()
        self.validates(context: &context)
        if context.hasErrors {
            throw ValidationError(context)
        }
    }
}

public struct ValidationContext<T: Validatable> {
    public var hasErrors: Bool {
        return self.errors.count > 0
    }
    
    public private(set) var errors = [any ValidatableError]()
    
    public mutating func addError(message: String) {
        self.addError(_MessageValidatableError(message: message))
    }
    
    public mutating func addError<V : Sendable>(name: String, actual: V, expected: V) {
        self.addError(_NamedValueError(name: name, actual: actual, expected: expected))
    }
    
    public mutating func addError<E: ValidatableError>(_ error: E) {
        self.errors.append(error)
    }
}

public protocol ValidatableError : Sendable {
    var message: String { get }
}

fileprivate struct _MessageValidatableError : ValidatableError {
    let message: String
}

fileprivate struct _NamedValueError<V : Sendable> : ValidatableError {
    let name: String
    let actual: V
    let expected: V
    
    var message: String {
        return "Value for \(name) was \(actual), expected \(expected)"
    }
}

public struct ValidationError<T : Validatable> : Error {
    public let underlyingErrors: [any ValidatableError]
    
    internal init(_ context: ValidationContext<T>) {
        self.underlyingErrors = context.errors
    }
}

#if canImport(Foundation)

import Foundation

extension ValidationError : CustomNSError {
    public static var errorDomain: String {
        return "com.angryboat.ABS-ValidationError"
    }
    
    public var errorCode: Int {
        return 1001
    }
    
    public var userInfo: [String : Any] {
        let sourceType = String(describing: T.self)
        return [
            NSLocalizedFailureReasonErrorKey: String(localized: "\(sourceType) failed validation", comment: "<Type> failed validation")
        ]
    }
}

#endif
