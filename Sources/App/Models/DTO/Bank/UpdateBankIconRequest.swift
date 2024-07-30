//
//  UpdateBankIconRequest.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - UpdateBankIconRequest
struct UpdateBankIconRequest: Content {
    let bankIcon: Data
}

// MARK: - Validatable
extension UpdateBankIconRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("bankIcon", as: Data.self, is: !.empty)
    }
}

