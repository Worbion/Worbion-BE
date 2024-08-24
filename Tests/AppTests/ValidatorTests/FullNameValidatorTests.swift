//
//  FullNameValidatorTests.swift
//  
//
//  Created by Cemal on 24.08.2024.
//

@testable import App
import XCTVapor

final class FullNameValidatorTests: XCTestCase {
    
    func testFullNameValidator_should_success_when_FullNames_valid() async throws {
        let validFullNames = [
            "Cemal Tüysüz",
            "Cemal Tüysüz",
            "Anna-Maria O'Neill",
            "李 小龙",
            "Jean-Claude Van Damme",
        ]
        
        validFullNames.forEach { fullName in
            let validator = FullNameValidator(fullNameStr: fullName)
            let isFailure = validator.isFailure
            assert(!isFailure, "\(fullName) is not valid")
        }
    }
    
    func testFullNameValidator_should_failure_when_FullNames_not_valid() async throws {
        let invalidFullNames = [
            "Cemal_tuysuz",
            "cemal tuysuz1",
            "cemaltuysuz",
            "cemal"
        ]
        
        invalidFullNames.forEach { invalidFullName in
            let validator = FullNameValidator(fullNameStr: invalidFullName)
            let isFailure = validator.isFailure
            assert(isFailure, "\(invalidFullName) should be failure. But passed.")
        }
    }
}


