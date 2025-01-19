//
//  PushController.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/19/25.
//

import Foundation

public enum PushController {
}

extension Notification.Name {
    public static let pushControllerRequestedAuthorization = Notification.Name("com.angryboat.pushControllerRequestedAuthorization")
}

#if canImport(UserNotifications)

import UserNotifications

extension PushController {
    public static func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        return await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }
    
    public static func requestAuthorization(option: UNAuthorizationOptions) async throws -> Bool {
        let result = try await UNUserNotificationCenter.current().requestAuthorization(options: option)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .pushControllerRequestedAuthorization, object: result)
        }
        
        return result
    }
}

#endif
