//
//  CreateBankRequest.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - CreateBankRequest
struct CreateBankRequest: Content {
    let bankName: String
    let bankIcon: Data
    let ibanCode: String
}

// MARK: - Validatable
extension CreateBankRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("bankName", as: String.self, is: !.empty)
        validations.add("bankIcon", as: Data.self, is: !.empty)
        validations.add("ibanCode", as: String.self, is: !.empty)
    }
}

// MARK: - CreateBankRequest + BankEntity
extension BankEntity {
    convenience init(
        create request: CreateBankRequest,
        icon url: String
    ) {
        self.init(bankName: request.bankName, iconUrl: url, ibankCode: request.ibanCode)
    }
}
