//
//  ModelContainerProvider.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/17/25.
//

import SwiftData

public enum ModelContainerProvider {
    public static var memoryOnlyLaunchFlag: String { "--memory-database" }
    
    public static var isFlaggedForMemoryOnly: Bool {
        CommandLine.arguments.contains(memoryOnlyLaunchFlag)
    }
}
