//
//  PhoneNumberValidatorTests.swift
//
//
//  Created by Cemal on 24.08.2024.
//

@testable import App
import XCTVapor

final class PhoneNumberValidatorTests: XCTestCase {
    
    func testPhoneNumberValidator_should_success_when_Phones_valid() async throws {
        let validPhoneNumbers = [
            "+12025550143",
            "+14155552671",
            "+902123456789",
            "+905555555555",
            "+49301234567",
            "+491751234567",
            "+442079460958",
            "+441632960961",
            "+33170189940",
            "+33612345678",
        ]
        
        validPhoneNumbers.forEach { validPhone in
            let validator = PhoneNumberValidator(phoneNumberStr: validPhone)
            let isSuccess = !validator.isFailure
            assert(isSuccess, "|\(validPhone)| phone number is not valid")
        }
    }
    
    func testPhoneNumberValidator_should_failure_when_Phones_not_valid() async throws {
        let invalidPhones = [
            "+1202555",
            "12025550143",
            "+90215",
            "90212345678",
            "+493012345",
            "+0321234567",
            "+4420-79460958",
            "\n+4420-79460958",
            "+4420-79460958\n",
            " +4420-79460958",
            "+4420-79460958 ",
        ]
        
        invalidPhones.forEach { invalidPhone in
            let validator = PhoneNumberValidator(phoneNumberStr: invalidPhone)
            let isFailure = validator.isFailure
            assert(isFailure, "|\(invalidPhone)| phone should be invalid but passed from validator.")
        }
    }
}

