//
//  PersistentModel.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/20/25.
//

import Foundation
import SwiftData

extension PersistentModel {
    @inlinable
    public static func count(inContext context: ModelContext, where predicate: Predicate<Self>? = nil) throws -> Int {
        let fetch = FetchDescriptor<Self>(predicate: predicate)
        return try context.fetchCount(fetch)
    }
    
    @inlinable
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
    
    @inlinable
    public static func exists(inContext context: ModelContext, where predicate: Predicate<Self>? = nil, expectedCount: Int = 1) throws -> Bool {
        return try self.count(inContext: context, where: predicate) == expectedCount
    }
    
    @inlinable
    public static func first(inContext context: ModelContext, where predicate: Predicate<Self>? = nil, sortedBy: [SortDescriptor<Self>] = []) throws -> Self? {
        let results = try self.fetch(inContext: context, where: predicate, sortedBy: sortedBy, limit: 1)
        return results.first
    }
}

#if canImport(SwiftUI)

import SwiftUI

extension PersistentModel {
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
