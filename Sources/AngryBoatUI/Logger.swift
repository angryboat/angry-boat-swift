//
//  Logger.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/28/25.
//

import OSLog
import ABSFoundation

public let ViewLogger = Logger(category: "View")

import SwiftUI

extension View {
    /// Returns the global ViewLogger
    @inlinable
    public var logger: Logger { ViewLogger }
}
