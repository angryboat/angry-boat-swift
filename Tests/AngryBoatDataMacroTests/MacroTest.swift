//
//  MacroTest.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/18/25.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion

protocol MacroTest {
    var testMacros: [String : Macro.Type] { get }
}

extension MacroTest {
    func expand(_ code: SourceFileSyntax) -> Syntax {
        return code.expand(macros: testMacros) { source in
            return BasicMacroExpansionContext(lexicalContext: [source])
        }
    }
    
    func normalize(_ syntax: Syntax) -> String {
        return syntax.description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func normalize(_ string: String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
