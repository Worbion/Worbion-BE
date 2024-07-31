//
//  CreateUserBankAccountRequest.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - CreateUserBankAccountRequest
struct CreateUserBankAccountRequest: Content {
    let bankId: BankEntity.IDValue
    let fullName: String
    let bankAccount: String
}

// MARK: - Validatable
extension CreateUserBankAccountRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("bankId", as: Int64.self, is: .range(1...))
        validations.add("bankAccount", as: String.self, is: !.empty)
        validations.add("fullName", as: String.self, is: .init(validate: { fullNameStr in
            return FullNameValidator(fullNameStr: fullNameStr)
        }))
        validations.add("bankAccount", as: String.self, is: .init(validate: { ibanStr in
            return IBANValidator(ibanValueStr: ibanStr)
        }))
    }
}
