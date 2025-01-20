//
//  Helpers.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/20/25.
//

import SwiftSyntax

extension AttributeSyntax {
    func labeledArguments() -> [String: ExprSyntax] {
        guard case .argumentList(let arguments) = self.arguments else {
            return [:]
        }
        
        var result = [String: ExprSyntax]()
        
        for argument in arguments {
            guard let label = argument.label else { continue }
            
            result[label.text] = argument.expression
        }
        
        return result
    }
}

extension Dictionary where Key == String, Value == ExprSyntax {
    func optionalStringLiteralValue(for key: String) throws -> String? {
        guard let expression = self[key] else {
            return nil
        }
        guard let stringLiteral = expression.as(StringLiteralExprSyntax.self) else {
            throw MacroError.invalidArgumentType(String.self, key)
        }
        guard let string = stringLiteral.segments.first?.as(StringSegmentSyntax.self)?.content.text else {
            throw MacroError(name: "InvalidString", message: "The \(key) argument must be a non-empty string literal \(stringLiteral.description)")
        }
        return string
    }
}
