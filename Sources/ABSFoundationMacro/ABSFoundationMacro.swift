//
//  ABSFoundationMacro.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/18/25.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ABSFoundationMacro : CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        UUIDMacro.self,
        URLMacro.self,
        LocalizedEnumMacro.self,
    ]
}

public struct MacroError : Error, CustomStringConvertible {
    public let name: String
    public let message: String

    internal init(name: String, message: String) {
        self.name = name
        self.message = message
    }
    
    public var description: String {
        return "\(name): \(message)"
    }
    
    internal static func argumentError(_ message: String) -> MacroError {
        return MacroError(name: "ArgumentMacroError", message: message)
    }
    
    internal static func invalidArgumentType<V>(_ type: V.Type, _ index: Int) -> MacroError {
        return MacroError(name: "ArgumentMacroError", message: "Invalid argument at index \(index), expected: \(String(describing: type))")
    }
    
    internal static func invalidArgumentType<V>(_ type: V.Type, _ index: String) -> MacroError {
        return MacroError(name: "ArgumentMacroError", message: "Invalid argument for \(index), expected: \(String(describing: type))")
    }
    
    internal static func unknownLabeledArgument(_ name: String?) -> MacroError {
        if let name {
            return MacroError(name: "LabeledArgumentMacroError", message: "Unknown labeled argument: \(name)")
        }
        return MacroError(name: "LabeledArgumentMacroError", message: "Invalid labeld argument, label name is nil?")
    }
}
