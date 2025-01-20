//
//  Record.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/17/25.
//

import Foundation
import SwiftData
import OSLog

public protocol Record : PersistentModel {
}

extension Record {
    public static func count(inContext context: ModelContext, where predicate: Predicate<Self>? = nil) throws -> Int {
        let fetch = FetchDescriptor<Self>(predicate: predicate)
        return try context.fetchCount(fetch)
    }
    
    public static func fetch(inContext context: ModelContext, where predicate: Predicate<Self>? = nil, sortedBy: [SortDescriptor<Self>] = [], limit: Int? = nil, offset: Int? = nil) throws -> [Self] {
        var fetch = FetchDescriptor<Self>(predicate: predicate, sortBy: sortedBy)
        if let limit {
            fetch.fetchLimit = limit
        }
        if let offset {
            fetch.fetchOffset = offset
        }
        
        return try context.fetch(fetch)
    }
    
    public static func exists(inContext context: ModelContext, where predicate: Predicate<Self>? = nil, expectedCount: Int = 1) throws -> Bool {
        return try self.count(inContext: context, where: predicate) == expectedCount
    }
}

extension Record {
    public var logger: os.Logger { Logger }
}

#if canImport(SwiftUI)

import SwiftUI

extension Record {
    @MainActor
    public static func query(where predicate: () -> Predicate<Self>? = { nil }, sort: () -> [SortDescriptor<Self>] = { [] }) -> Query<Self, [Self]> {
        return Query(filter: predicate(), sort: sort())
    }
    
    @MainActor
    public static func query(where predicate: () -> Predicate<Self>? = { nil }, sort: () -> [SortDescriptor<Self>] = { [] }, animation: Animation) -> Query<Self, [Self]> {
        return Query(filter: predicate(), sort: sort(), animation: animation)
    }
}

#endif
