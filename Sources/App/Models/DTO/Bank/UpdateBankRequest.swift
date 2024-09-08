//
//  UpdateBankRequest.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - UpdateBankRequest
struct UpdateBankRequest: Content, Equatable {
    let bankName: String
    let ibanCode: String
}

// MARK: - Fake Update Request
fileprivate extension BankEntity {
    var fakeUpdateRequest: UpdateBankRequest {
        return .init(bankName: bankName, ibanCode: ibanCode)
    }
}

// MARK: - Compare and replace fields if needed
extension BankEntity {
    func updateFieldsIfNeeded(update request: UpdateBankRequest) -> Bool {
        guard fakeUpdateRequest != request else { return false }
        bankName = request.bankName
        ibanCode = request.ibanCode
        return true
    }
}

// MARK: - Validatable
extension UpdateBankRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("bankName", as: String.self, is: !.empty)
    }
}
