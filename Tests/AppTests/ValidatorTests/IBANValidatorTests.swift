//
//  IBANValidatorTests.swift
//
//
//  Created by Cemal on 30.07.2024.
//

@testable import App
import XCTVapor

final class IBANValidatorTests: XCTestCase {
    
    func testIBAN_should_success_when_IBANs_valid() async throws {
        let validIBANs = [
            "TR480001001043791735745001",
            "TR210001001043791735745002",
            "TR510006701000000042609049",
            "TR480006701000000042609103",
            "TR710006701000000042609077"
        ]
        
        validIBANs.forEach { validIban in
            let validator = IBANValidator(ibanValueStr: validIban)
            let isSuccess = !validator.isFailure
            assert(isSuccess, "-\(validIban)- iban is not valid")
        }
    }
    
    func testIBAN_should_failure_when_IBANs_not_valid() async throws {
        let invalidIbans = [
            "TR480001001043791735111001", // changed numbers
            "TR21000100104379173574", // low count
            "TR51000670100000004260904900", // up count
            "480006701000000042609103" // No TR
        ]
        
        invalidIbans.forEach { validIban in
            let validator = IBANValidator(ibanValueStr: validIban)
            let isFailure = validator.isFailure
            assert(isFailure, "\(validIban) iban should be invalid but passed from validator.")
        }
    }
}

