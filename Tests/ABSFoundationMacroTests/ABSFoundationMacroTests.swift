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
    
    #expect(equal(result, expected))
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
    
    #expect(equal(result, expected))
}


@Test
func LocalizedEnumMacroTest() {
    let source: SourceFileSyntax =
    """
    @LocalizedEnum
    enum Foo {
        case bar
        case baz
    }
    """
    
    let expected =
    """
    enum Foo {
        case bar
        case baz
    
        var localizedDescription: String {
            switch self {
            case .bar:
                return String(localized: "Foo.bar")
            case .baz:
                return String(localized: "Foo.baz")
            }
        }
    }
    """
    
    let result = source.expand(macros: ["LocalizedEnum": LocalizedEnumMacro.self]) {
        return BasicMacroExpansionContext(lexicalContext: [$0])
    }
    
    #expect(equal(result, expected))
}

@Test
func LocalizedEnumMacroWithCustomPrefixTest() {
        let source: SourceFileSyntax =
        """
        @LocalizedEnum(prefix: "Enum")
        enum Foo {
            case bar
            case baz
        }
        """
        
        let expected =
        """
        enum Foo {
            case bar
            case baz
        
            var localizedDescription: String {
                switch self {
                case .bar:
                    return String(localized: "Enum.Foo.bar")
                case .baz:
                    return String(localized: "Enum.Foo.baz")
                }
            }
        }
        """
        
        let result = source.expand(macros: ["LocalizedEnum": LocalizedEnumMacro.self]) {
            return BasicMacroExpansionContext(lexicalContext: [$0])
        }
        
        #expect(equal(result, expected))
}

@Test
func LocalizedEnumMacroWithCustomPrefixAndSeparator() {
        let source: SourceFileSyntax =
        """
        @LocalizedEnum(prefix: "Enum", separator: "#")
        enum Foo {
            case bar
            case baz
        }
        """
        
        let expected =
        """
        enum Foo {
            case bar
            case baz
        
            var localizedDescription: String {
                switch self {
                case .bar:
                    return String(localized: "Enum#Foo#bar")
                case .baz:
                    return String(localized: "Enum#Foo#baz")
                }
            }
        }
        """
        
        let result = source.expand(macros: ["LocalizedEnum": LocalizedEnumMacro.self]) {
            return BasicMacroExpansionContext(lexicalContext: [$0])
        }
        
        #expect(equal(result, expected))
}

@Test
func LocalizedEnumMacroWithCustomPrefixAndSeparatorAndBundle() {
        let source: SourceFileSyntax =
        """
        @LocalizedEnum(prefix: "Enum", separator: "#", bundle: .main)
        enum Foo {
            case bar
            case baz
        }
        """
        
        let expected =
        """
        enum Foo {
            case bar
            case baz
        
            var localizedDescription: String {
                switch self {
                case .bar:
                    return String(localized: "Enum#Foo#bar", bundle: .main)
                case .baz:
                    return String(localized: "Enum#Foo#baz", bundle: .main)
                }
            }
        }
        """
        
        let result = source.expand(macros: ["LocalizedEnum": LocalizedEnumMacro.self]) {
            return BasicMacroExpansionContext(lexicalContext: [$0])
        }
        
        #expect(equal(result, expected))
}

func equal(_ lhs: Syntax, _ rhs: String) -> Bool {
    lhs.description.trimmingCharacters(in: .whitespacesAndNewlines) == rhs.trimmingCharacters(in: .whitespacesAndNewlines)
}
