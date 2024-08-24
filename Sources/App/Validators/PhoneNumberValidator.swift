//
//  PhoneNumberValidator.swift
//
//
//  Created by Cemal on 24.08.2024.
//

import Vapor

// MARK: - PhoneNumberValidator
struct PhoneNumberValidator {
    private var phoneNumberStr: String
    
    init(phoneNumberStr: String) {
        self.phoneNumberStr = phoneNumberStr
    }
}

extension PhoneNumberValidator: BaseValidatorResult {
    var failureDescription: String? {
        return "\(phoneNumberStr) is not valid phone number."
    }
    
    func doValidate() -> Bool {
        guard StringOutWhiteSpaceAndNewLineValidator(string: phoneNumberStr).isFailure else { return false }
        
        guard phoneNumberStr.hasPrefix("+") else {
            return false
        }

        let strippedNumber = String(phoneNumberStr.dropFirst())
        
        let isNumeric = strippedNumber.allSatisfy { $0.isNumber }
        if !isNumeric {
            return false
        }
        
        let length = strippedNumber.count
        return length >= 11 && length <= 15
    }
}
