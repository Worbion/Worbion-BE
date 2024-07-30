//
//  UpdateBankRequest.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - UpdateBankRequest
struct UpdateBankRequest: Content {
    let bankName: String
}

// MARK: - Validatable
extension UpdateBankRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("bankName", as: String.self, is: !.empty)
    }
}
