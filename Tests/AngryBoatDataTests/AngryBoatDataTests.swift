//
//  AngryBoatDataTests.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/17/25.
//

import Testing
import SwiftData
@testable import AngryBoatData

@Model
final class Widget : Record {
    @Attribute
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

@SeedDataProvider
struct WidgetOneSeed {
    @MainActor
    func generate() throws {
        create {
            Widget(name: "One")
        }
    }
}

@SeedDataProvider
struct WidgetTwoSeed {
    @MainActor
    func generate() throws {
        create {
            Widget(name: "Two")
        }
    }
}

struct ModelContainerProviderTests {
    let container: ModelContainer
    
    init() throws {
        self.container = try ModelContainer(for: Widget.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
    
    @Test
    @MainActor
    func seedUsingMultipeSeedInstances() throws {
        try SeedData(in: container, WidgetOneSeed.self, WidgetTwoSeed.self)
        
        #expect(container.mainContext.hasChanges == false)
        
        let count = try Widget.count(inContext: container.mainContext)
        #expect(count == 2)
    }
}
