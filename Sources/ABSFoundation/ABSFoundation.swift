//
//  ABSFoundation.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/18/25.
//

import Foundation

@freestanding(expression)
public macro UUID(_ uuidString: String) -> UUID = #externalMacro(module: "ABSFoundationMacro", type: "UUIDMacro")

@freestanding(expression)
public macro URL(_ urlString: String) -> URL = #externalMacro(module: "ABSFoundationMacro", type: "URLMacro")
