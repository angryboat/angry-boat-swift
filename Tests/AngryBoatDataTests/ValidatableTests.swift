//
//  ValidatableTests.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 2/24/25.
//

import Testing

@testable import AngryBoatData

struct TestValidatable : Validatable {
    let value: Int
    
    func validates(context: inout ValidationContext<Self>) {
        if value != 0 {
            context.addError(name: "value", actual: value, expected: 0)
        }
    }
}

@Test
func testValidatableSuccess() {
    let v = TestValidatable(value: 0)
    
    #expect(throws: Never.self) {
        try v.validate()
    }
}

@Test
func testValidatableFailure() {
    let v = TestValidatable(value: 1)
    
    #expect(throws: ValidationError<TestValidatable>.self) {
        try v.validate()
    }
}
