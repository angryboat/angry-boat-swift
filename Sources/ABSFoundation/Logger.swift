//
//  Logger.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/18/25.
//

import Foundation
import OSLog

extension Logger {
    public init(category: String, forBundle bundle: Bundle = .main) {
        self.init(subsystem: bundle.bundleIdentifier ?? "com.angryboat.ABSFoundation-Unknown", category: category)
    }
}

@LocalizedEnum(bundle: .main)
enum Foo {
    case bar
    case baz
}
