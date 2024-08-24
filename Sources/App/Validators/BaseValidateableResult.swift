//
//  BaseValidateableResult.swift
//
//
//  Created by Cemal on 24.08.2024.
//

import Vapor

// MARK: - BaseValidatorResult
protocol BaseValidatorResult: ValidatorResult {
    func doValidate() -> Bool
}

extension BaseValidatorResult {
    var isFailure: Bool {
        let isValid = doValidate()
        return !isValid
    }
    var successDescription: String? {
        return nil
    }
}
