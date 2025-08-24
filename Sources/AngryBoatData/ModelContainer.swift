//
//  ModelContainer.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 8/24/25.
//

import Foundation
import SwiftData
import OSLog

extension ModelContainer {
    nonisolated public static let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.angryboat.AngryBoatData", category: "Data")
    
    public enum LaunchFlags {
        public static var isMemoryDatabaseEnabled: Bool {
            CommandLine.arguments.contains("--in-memory-database")
        }
        
        public static var isCloudKitDisabled: Bool {
            CommandLine.arguments.contains("--disable-cloudkit")
        }
    }
    
    public convenience init(for scheme: Schema, inMemoryOnly: Bool, cloudKitEnabled: Bool = true) throws {
        let useMemoryOnlyConfig = inMemoryOnly || LaunchFlags.isMemoryDatabaseEnabled
        #if targetEnvironment(simulator)
        let useCloudKit = false
        #else
        let useCloudKit = cloudKitEnabled && (!useMemoryOnlyConfig || !LaunchFlags.isCloudKitDisabled)
        #endif
        
        let cloudKit: ModelConfiguration.CloudKitDatabase = useCloudKit ? .automatic : .none
        let config = ModelConfiguration(isStoredInMemoryOnly: useMemoryOnlyConfig, cloudKitDatabase: cloudKit)
        
        Self.logger.debug("Setup ModelContainer inMemory:\(useMemoryOnlyConfig) cloudKit:\(useCloudKit)")
        
        try self.init(for: scheme, configurations: [config])
    }
}
