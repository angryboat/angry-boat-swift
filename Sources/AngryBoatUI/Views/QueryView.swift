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
public struct QueryView<Model: PersistentModel, Content: View> : View {
    private let content: ([Model]) -> Content
    
    @Query
    private var results: [Model]
    
    public init(filter predicate: Predicate<Model>? = nil, sort descriptors: [SortDescriptor<Model>] = [], transaction: Transaction? = nil, @ViewBuilder content: @escaping ([Model]) -> Content) {
        self.content = content
        self._results = Query(filter: predicate, sort: descriptors, transaction: transaction)
    }
    
    public init(fetch: FetchDescriptor<Model>, animation: Animation = .default, @ViewBuilder content: @escaping ([Model]) -> Content) {
        self.content = content
        self._results = Query(fetch, animation: animation)
    }
    
    public var body: some View {
        content(results)
    }
}
