//
//  Record.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/17/25.
//

import Foundation
import SwiftData
import OSLog

public protocol Record : PersistentModel {
}

extension Record {
    public var logger: os.Logger { Logger }
}
