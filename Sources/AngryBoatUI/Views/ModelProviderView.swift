//
//  ModelProviderView.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 3/13/26.
//

import SwiftUI
import SwiftData

/// A view that asynchronously loads a `PersistentModel` by its identifier and
/// provides it to a content builder.
///
/// `ModelProviderView` resolves a SwiftData model from the environment's
/// `ModelContext` using a `PersistentIdentifier`. The model is loaded when the
/// view appears and reloaded whenever the identifier changes.
///
/// The content closure receives an optional model — `nil` while loading or if
/// the identifier can't be resolved.
///
/// ```swift
/// ModelProviderView(Item.self, id: itemID) { item in
///     if let item {
///         Text(item.name)
///     } else {
///         ProgressView()
///     }
/// }
/// ```
///
/// For custom resolution logic, pass a `loader` closure:
///
/// ```swift
/// ModelProviderView(Item.self, id: itemID, loader: { context, id in
///     try? context.fetch(/* custom descriptor */).first
/// }) { item in
///     // ...
/// }
/// ```
public struct ModelProviderView<Model : PersistentModel, Content: View>: View {
    private let id: PersistentIdentifier
    private let content: (Model?) -> Content
    private let loader: (ModelContext, PersistentIdentifier) -> Model?

    @Environment(\.modelContext)
    private var modelContext

    @State
    private var model: Model?

    /// Creates a model provider that resolves the model using
    /// `ModelContext.registeredModel(for:)`.
    ///
    /// - Parameters:
    ///   - modelType: The `PersistentModel` type to resolve.
    ///   - id: The persistent identifier of the model to load.
    ///   - content: A view builder that receives the resolved model, or `nil`
    ///     if the model hasn't loaded or can't be found.
    public init(_ modelType: Model.Type, id: PersistentIdentifier, @ViewBuilder content: @escaping (Model?) -> Content) {
        self.id = id
        self.content = content
        self.loader = { $0.registeredModel(for: $1) }
    }

    /// Creates a model provider with a custom loader closure.
    ///
    /// - Parameters:
    ///   - modelType: The `PersistentModel` type to resolve.
    ///   - id: The persistent identifier of the model to load.
    ///   - loader: A closure that resolves the model from a `ModelContext` and
    ///     `PersistentIdentifier`. Use this for custom fetch logic.
    ///   - content: A view builder that receives the resolved model, or `nil`
    ///     if the model hasn't loaded or can't be found.
    public init(_ modelType: Model.Type, id: PersistentIdentifier, loader: @escaping (ModelContext, PersistentIdentifier) -> Model?, @ViewBuilder content: @escaping (Model?) -> Content) {
        self.id = id
        self.content = content
        self.loader = loader
    }

    public var body: some View {
        self.content(model).id(id).task(id: id) {
            self.model = self.loader(self.modelContext, self.id)
        }
    }
}
