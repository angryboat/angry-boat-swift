//
//  SeedDataProviderMacro.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/18/25.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct SeedDataProviderMacro : MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let initializer: DeclSyntax =
            """
            public init(modelContainer: ModelContainer) {
                self.modelContainer = modelContainer
            }
            """
        
        let modelContainerVariable: DeclSyntax =
            """
            public let modelContainer: ModelContainer
            """
        
        
        return [
            modelContainerVariable,
            initializer
        ]
    }
}

extension SeedDataProviderMacro: ExtensionMacro {
  public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
      return [try ExtensionDeclSyntax("extension \(type): SeedDataProvider {}")]
  }
}
