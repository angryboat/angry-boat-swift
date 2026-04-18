//
//  ULIDMacro.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 4/18/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct ULIDMacro: ExpressionMacro {
    private static let crockfordAlphabet = Set("0123456789ABCDEFGHJKMNPQRSTVWXYZabcdefghjkmnpqrstvwxyz")

    public static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            throw MacroError.argumentError("Missing required argument at index 0")
        }
        guard let segments = argument.as(StringLiteralExprSyntax.self)?.segments else {
            throw MacroError.invalidArgumentType(String.self, 0)
        }

        let string = segments.description

        guard string.count == 26 else {
            throw MacroError(name: "ULIDError", message: "ULID string must be 26 characters, got \(string.count)")
        }
        for char in string {
            guard crockfordAlphabet.contains(char) else {
                throw MacroError(name: "ULIDError", message: "ULID string contains invalid character: '\(char)'")
            }
        }
        guard let first = string.first, "01234567".contains(first.uppercased()) else {
            throw MacroError(name: "ULIDError", message: "ULID string overflows: first character must be 0–7")
        }

        return "try! ULID(string: \(argument))"
    }
}
