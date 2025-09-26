//
//  TaskButton.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 9/26/25.
//

import SwiftUI

/// An error that can be thrown to abort a task without triggering error handling.
/// When this error is thrown, the TaskButton will not display an error alert.
struct TaskButtonAbort : Error {
}

/// A button that executes an async task with built-in loading states and error handling.
///
/// TaskButton provides automatic UI states for task execution:
/// - Shows a progress indicator while the task is running
/// - Optionally disables the button during execution
/// - Displays error alerts when tasks fail
/// - Supports custom error handling and working labels
struct TaskButton<Label: View> : View {
    private let label: Label
    private let action: () async throws -> Void

    fileprivate var workingLabel: LocalizedStringResource?
    fileprivate var innerPadding = EdgeInsets()
    fileprivate var errorMessage: LocalizedStringResource? = "TaskButtonErrorAlertMessage"
    fileprivate var onError: ((Error) -> Error?) = { $0 }
    fileprivate var shouldDisable: Bool = true
    fileprivate var isWorking: Binding<Bool>? = nil
    fileprivate var showProgressView: Bool = true
    
    @State
    private var task: Task<Void, Never>? = nil

    @State
    private var localizedError: ButtonActionError? = nil

    @State
    private var presentingError: Bool = false

    /// Creates a TaskButton with an async action and custom label.
    /// - Parameters:
    ///   - action: The async action to execute when the button is tapped
    ///   - label: A ViewBuilder closure that creates the button's label
    init(action: @escaping @MainActor () async throws -> Void, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.action = action
    }
    
    var body: some View {
        Button(action: _action) {
            if task == nil || showProgressView == false {
                label.padding(innerPadding)
            } else {
                HStack {
                    ProgressView().progressViewStyle(.circular)
                    if let workingLabel {
                        Text(workingLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }.padding(innerPadding)
            }
        }
        .disabled(shouldDisable && task != nil)
        .alert(isPresented: $presentingError, error: localizedError) { error in
            Button(role: .cancel, action: _reset) {
                Text("TaskButtonErrorAlertCancel")
            }
        } message: { error in
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onChange(of: task, initial: true) { oldValue, newValue in
            if let isWorking, isWorking.wrappedValue != (newValue != nil) {
                withAnimation { isWorking.wrappedValue = newValue != nil }
            }
        }
    }
    
    /// Resets the error state and dismisses the error alert
    private func _reset() {
        withAnimation {
            presentingError = false
            localizedError = nil
        }
    }

    /// Executes the button's action, handling cancellation and error states
    private func _action() {
        self.task?.cancel()
        withAnimation {
            self.task = Task {
                do {
                    try await action()
                } catch is TaskButtonAbort {
                    // no-op
                } catch {
                    if let err = onError(error) {
                        withAnimation {
                            self.localizedError = ButtonActionError(error: err)
                            self.presentingError = true
                        }
                    }
                }
                if Task.isCancelled == false {
                    withAnimation { self.task = nil }
                }
            }
        }
    }
}

fileprivate struct ButtonActionError : LocalizedError {
    let error: Error

    var errorDescription: String? {
        guard let err = error as? LocalizedError else {
            return error.localizedDescription
        }
        return err.errorDescription
    }

    var failureReason: String? {
        guard let err = error as? LocalizedError else {
            return nil
        }
        return err.failureReason
    }

    var recoverySuggestion: String? {
        guard let err = error as? LocalizedError else {
            return nil
        }
        return err.recoverySuggestion
    }

    var helpAnchor: String? {
        guard let err = error as? LocalizedError else {
            return nil
        }
        return err.helpAnchor
    }
}

extension TaskButton {
    /// Sets the inner padding for the button content.
    /// - Parameter insets: The edge insets to apply as padding
    /// - Returns: A modified TaskButton with the specified padding
    func innerPadding(_ insets: EdgeInsets) -> Self {
        var button = self
        button.innerPadding = insets
        return button
    }

    /// Sets the error message displayed in alert dialogs.
    /// - Parameter message: The localized error message, or nil to disable error alerts
    /// - Returns: A modified TaskButton with the specified error message
    func errorMessage(_ message: LocalizedStringResource?) -> Self {
        var button = self
        button.errorMessage = message
        return button
    }

    /// Sets a custom error handler for task failures.
    /// - Parameter action: A closure that receives the error and returns a modified error to display, or nil to suppress the alert
    /// - Returns: A modified TaskButton with the specified error handler
    func onError(_ action: @escaping @MainActor (Error) -> Error?) -> Self {
        var button = self
        button.onError = action
        return button
    }

    /// Controls whether the button is disabled while a task is running.
    /// - Parameter shouldDisable: Whether to disable the button during task execution
    /// - Returns: A modified TaskButton with the specified disable behavior
    func shouldDisable(_ shouldDisable: Bool) -> Self {
        var button = self
        button.shouldDisable = shouldDisable
        return button
    }

    /// Binds the working state to an external boolean binding.
    /// - Parameter isWorking: A binding that will be updated to reflect the task's running state
    /// - Returns: A modified TaskButton with the specified working state binding
    func isWorking(_ isWorking: Binding<Bool>?) -> Self {
        var button = self
        button.isWorking = isWorking
        return button
    }

    /// Controls whether to show the progress view while a task is running.
    /// - Parameter showProgressView: Whether to display the progress indicator
    /// - Returns: A modified TaskButton with the specified progress view behavior
    func showProgressView(_ showProgressView: Bool) -> Self {
        var button = self
        button.showProgressView = showProgressView
        return button
    }

    /// Sets a label to display alongside the progress indicator while working.
    /// - Parameter workingLabel: The localized label to show during task execution
    /// - Returns: A modified TaskButton with the specified working label
    func workingLabel(_ workingLabel: LocalizedStringResource?) -> Self {
        var button = self
        button.workingLabel = workingLabel
        return button
    }
}

#Preview {
    TaskButton {
        try await Task.sleep(for: .seconds(4))
    } label: {
        Label("Generate", systemImage: "wand.and.sparkles")
    }
    .shouldDisable(false)
    .buttonStyle(.bordered)
}
