//
//  SeedDataProviderMacroTests.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/18/25.
//

import Testing
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion

@testable import AngryBoatDataMacro

struct SeedDataProviderMacroTests : MacroTest {
    let testMacros: [String : Macro.Type] = [
        "SeedDataProvider": SeedDataProviderMacro.self
    ]
    
    @Test
    func addMacroMethods() {
        let source: SourceFileSyntax =
            """
            @SeedDataProvider
            struct TestProvider {
            }
            """
        
        let expanded = expand(source)
        
        let expected =
            """
            struct TestProvider {
            
                public let modelContainer: ModelContainer
            
                public init(modelContainer: ModelContainer) {
                    self.modelContainer = modelContainer
                }
            }
            
            extension TestProvider: SeedDataProvider {
            }
            """
        
        #expect(normalize(expanded) == normalize(expected))
    }
}
