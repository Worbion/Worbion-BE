//
//  StringDoubleValidator.swift
//
//
//  Created by Cemal on 29.07.2024.
//

import Vapor

// MARK: - StringDoubleValidator
struct StringDoubleValidator: ValidatorResult {
    private var isValid: Bool
    private var valueStr: String
    
    var isFailure: Bool {
        return !isValid
    }
    
    var successDescription: String? {
        return nil
    }
    
    var failureDescription: String? {
        return "\(valueStr) is not double type str."
    }
    
    init(valueStr: String) {
        self.valueStr = valueStr
        let doubleValue = Double(valueStr)
        isValid = doubleValue != nil
    }
}
