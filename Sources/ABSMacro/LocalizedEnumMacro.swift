//
//  LocalizedEnumMacro.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/20/25.
//


import SwiftSyntax
import SwiftSyntaxMacros

public struct LocalizedEnumMacro : MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw MacroError(name: "Invalid Usage", message: "LocalizedEnum must be applied to an enum declaration")
        }
        
        let arguments = node.labeledArguments()
        
        let prefix = try arguments.optionalStringLiteralValue(for: "prefix")
        let separator = try arguments.optionalStringLiteralValue(for: "separator") ?? "."
        let visibility = try arguments.optionalStringLiteralValue(for: "visibility") ?? ""
        
        var optionalBundleExpr = ""
        if let expression = arguments["bundle"] {
            optionalBundleExpr = ", bundle: \(expression.description)"
        }
        
        let caseNames = enumDecl.memberBlock.members.compactMap { member in
            if let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) {
                return caseDecl.elements.map(\.name)
            }
            return nil
        }.flatMap(\.self)
        
        var keyPath: [String] = []
        if let prefix = prefix {
            keyPath.append(prefix)
        }
        keyPath.append(enumDecl.name.text)
        
        let cases = caseNames.map { token in
            "case .\(token): return String(localized: \"\(keyPath.joined(separator: separator))\(separator)\(token)\"\(optionalBundleExpr))"
        }
        
        let switchStatement =
        """
        switch self {
        \(cases.joined(separator: "\n"))
        }
        """
        
        let localizedString = try VariableDeclSyntax("\(raw: visibility) var localizedDescription: String { \(raw: switchStatement) }")
        
        return [
            DeclSyntax(localizedString)
        ]
    }
}
