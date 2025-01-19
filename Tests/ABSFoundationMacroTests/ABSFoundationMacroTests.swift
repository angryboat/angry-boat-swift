//
//  ABSFoundationMacroTests.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/18/25.
//

import Testing
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion

@testable import ABSFoundationMacro

@Test
func UUIDMacroTest() {
    let source: SourceFileSyntax =
        """
        #UUID("133018E3-F0C9-4344-9E56-96AA60D5DD82")
        """
    
    let expected = "UUID(uuidString: \"133018E3-F0C9-4344-9E56-96AA60D5DD82\")!"
    
    let result = source.expand(macros: ["UUID": UUIDMacro.self]) {
        return BasicMacroExpansionContext(lexicalContext: [$0])
    }
    
    #expect(result.description == expected)
}

@Test
func URLMacroTest() {
    let source: SourceFileSyntax =
        """
        #URL("https://angryboat.com")
        """
    
    let expected = "URL(string: \"https://angryboat.com\")!"
    
    let result = source.expand(macros: ["URL": URLMacro.self]) {
        return BasicMacroExpansionContext(lexicalContext: [$0])
    }
    
    #expect(result.description == expected)
}

