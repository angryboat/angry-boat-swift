//
//  SeedDataProvider.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/17/25.
//

import SwiftData

@attached(member, names: named(init), named(modelContainer))
@attached(extension, conformances: SeedDataProvider)
public macro SeedDataProvider() = #externalMacro(module: "ABSMacro", type: "SeedDataProviderMacro")

@MainActor
public protocol SeedDataProvider {
    func shouldGenerate() throws -> Bool
    
    func generate() throws
    
    func prepare() throws
    
    func cleanup() throws
    
    var modelContainer: ModelContainer { get }
    
    init(modelContainer: ModelContainer)
}

extension SeedDataProvider {
    @MainActor
    public var modelContext: ModelContext { self.modelContainer.mainContext }
    
    public func shouldGenerate() throws -> Bool {
        return true
    }
    
    public func prepare() throws {
        
    }
    
    public func cleanup() throws {
        
    }
    
    @discardableResult
    @MainActor
    public func create<T : PersistentModel>(_ builder: () throws -> T) rethrows -> T {
        let model = try builder()
        self.modelContext.insert(model)
        return model
    }
    
    @MainActor
    fileprivate func finalize() throws {
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}

@MainActor
public func SeedData<S: SeedDataProvider>(_ seedType: S.Type, in container: ModelContainer) throws {
    let instance = seedType.init(modelContainer: container)
    
    guard try instance.shouldGenerate() else {
        return
    }
    
    Logger.trace("Generating Seed Data - \(String(describing: instance))")
    
    try instance.prepare()
    try instance.generate()
    try instance.cleanup()
    try instance.finalize()
}

@MainActor
public func SeedData(in container: ModelContainer, _ seed: any SeedDataProvider.Type...) throws {
    for seedType in seed {
        try SeedData(seedType, in: container)
    }
}
