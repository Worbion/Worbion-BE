//
//  StringDoubleValidator.swift
//
//
//  Created by Cemal on 29.07.2024.
//

import Vapor

// MARK: - StringDoubleValidator
struct StringDoubleValidator: ValidatorResult {
    private var valueStr: String
    
    init(valueStr: String) {
        self.valueStr = valueStr
    }
}

// MARK: - BaseValidatorResult
extension StringDoubleValidator: BaseValidatorResult {
    var failureDescription: String? {
        return "\(valueStr) is not double type str."
    }
    
    func doValidate() -> Bool {
        let doubleValue = Double(valueStr)
        return doubleValue != nil
    }
}
