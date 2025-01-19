//
//  LoggerTests.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/18/25.
//

import Testing
import OSLog

@testable import ABSFoundation

@Test
func loggerInitWithBundle() {
    let logger = Logger(category: "Testing")
    
    logger.info("Hello World")
}
