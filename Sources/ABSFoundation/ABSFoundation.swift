//
//  ABSFoundation.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/18/25.
//

import Foundation

@freestanding(expression)
public macro UUID(_ uuidString: String) -> UUID = #externalMacro(module: "ABSMacro", type: "UUIDMacro")

@freestanding(expression)
public macro URL(_ urlString: String) -> URL = #externalMacro(module: "ABSMacro", type: "URLMacro")

@attached(member, names: named(localizedDescription))
public macro LocalizedEnum(prefix: String = "", separator: String = ".", visibility: String = "", bundle: Bundle? = nil) = #externalMacro(module: "ABSMacro", type: "LocalizedEnumMacro")
