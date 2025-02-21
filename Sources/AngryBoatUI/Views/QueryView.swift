//
//  QueryView.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 2/21/25.
//

import SwiftUI
import SwiftData

/// SwiftData Query View
///
/// If the query needs to be dynamically managed the calling view can store the filter & sort in State to allow UI to update the values.
/// When you don't need dynamic filter or sorting, then @Query is a better option in the calling view.
@MainActor
public struct QueryView<Element: PersistentModel, Content : View> : View {
    private let contentProvider: ([Element]) -> Content
    
    private var elementQuery: Query<Element, [Element]>
    
    public init(filter predicate: Predicate<Element>? = nil, sort descriptors: [SortDescriptor<Element>] = [], transaction: Transaction? = nil, @ViewBuilder content: @escaping ([Element]) -> Content) {
        self.contentProvider = content
        self.elementQuery = Query(filter: predicate, sort: descriptors, transaction: transaction)
    }
    
    public init(fetch: FetchDescriptor<Element>, animation: Animation = .default, @ViewBuilder content: @escaping ([Element]) -> Content) {
        self.contentProvider = content
        self.elementQuery = Query(fetch, animation: animation)
    }
    
    public var body: some View {
        self.contentProvider(elementQuery.wrappedValue)
    }
}
