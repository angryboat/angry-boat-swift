//
//  Debouncer.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/16/26.
//

import Foundation

/// An observable wrapper that debounces value changes.
///
/// When `value` is updated, the debouncer waits for the specified duration before
/// propagating the change to `result`. If `value` changes again before the duration
/// elapses, the timer resets. This is useful for rate-limiting updates, such as
/// filtering search results as the user types.
///
/// ```swift
/// @State private var debouncer = Debouncer<String>(duration: .milliseconds(300))
///
/// var body: some View {
///     TextField("Search", text: $debouncer.value)
///         .onChange(of: debouncer.result) { _, query in
///             performSearch(query)
///         }
/// }
/// ```
@MainActor
@Observable
public final class Debouncer<Value : Equatable> {
    /// The input value. Changes trigger the debounce timer.
    public var value: Value {
        didSet {
            guard oldValue != self.value else { return }
            
            self.task?.cancel()
            self.task = Task {
                try? await Task.sleep(for: self.duration)
                guard Task.isCancelled == false else { return }
                self.result = self.value
            }
        }
    }
    
    /// The debounced output value, updated after the duration elapses without further changes.
    public private(set) var result: Value

    private let duration: Duration
    private var task: Task<Void, Never>?

    /// Creates a debouncer with an initial value and delay duration.
    /// - Parameters:
    ///   - value: The initial value for both `value` and `result`.
    ///   - duration: How long to wait after a change before updating `result`.
    public init(value: Value, duration: Duration) {
        self.value = value
        self.result = value
        self.duration = duration
    }
}

extension Debouncer where Value == String {
    /// Creates a string debouncer initialized to an empty string.
    /// - Parameter duration: How long to wait after a change before updating `result`.
    public convenience init(duration: Duration) {
        self.init(value: "", duration: duration)
    }
}
