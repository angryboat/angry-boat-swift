//
//  PushControllerStatusView.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/19/25.
//

#if canImport(UserNotifications)

import UserNotifications
import SwiftUI
import ABSFoundation

extension PushController {
    /// StatusView renders the provided content with the current UNAuthorizationStatus passed to the content builder.
    ///
    /// Status is updated:
    ///  - On App activation (foreground)
    ///  - After PushController.requestAuthorization(option:)
    public struct StatusView<Content : View> : View {
        @Environment(\.scenePhase)
        private var scenePhase
        
        @ViewBuilder
        private let content: (UNAuthorizationStatus) -> Content
        
        @State
        private var status = UNAuthorizationStatus.notDetermined
        
        private var requestedAuthorizationPublisher: NotificationCenter.Publisher
        
        public init(@ViewBuilder content: @escaping (UNAuthorizationStatus) -> Content) {
            self.content = content
            self.requestedAuthorizationPublisher = NotificationCenter.default.publisher(for: .pushControllerRequestedAuthorization)
        }
        
        public var body: some View {
            content(status)
                .task(priority: .userInitiated, updateCurrentPushSettings)
                .onReceive(requestedAuthorizationPublisher, perform: pushControllerDidRequestAuthorization)
                .onChange(of: scenePhase, scenePhaseChange)
        }
        
        @Sendable
        private func updateCurrentPushSettings() async {
            self.status = await PushController.currentAuthorizationStatus()
        }
        
        private func scenePhaseChange(_: ScenePhase, newValue: ScenePhase) {
            guard newValue == .active else { return }
            
            Task(priority: .userInitiated) {
                await updateCurrentPushSettings()
            }
        }
        
        private func pushControllerDidRequestAuthorization(_: Notification) {
            Task(priority: .userInitiated) {
                await updateCurrentPushSettings()
            }
        }
    }
}

#endif
