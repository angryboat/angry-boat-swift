//
//  Helpers.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/28/25.
//

import Foundation
import SwiftSyntax

func equal(_ lhs: Syntax, _ rhs: String) -> Bool {
    lhs.description.trimmingCharacters(in: .whitespacesAndNewlines) == rhs.trimmingCharacters(in: .whitespacesAndNewlines)
}
