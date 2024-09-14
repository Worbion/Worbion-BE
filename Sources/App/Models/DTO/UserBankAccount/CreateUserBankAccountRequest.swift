//
//  CreateUserBankAccountRequest.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - CreateUserBankAccountRequest
struct CreateUserBankAccountRequest: Content {
    let fullName: String
    let bankAccount: String
}

// MARK: - Validatable
extension CreateUserBankAccountRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("bankAccount", as: String.self, is: !.empty)
        validations.add("fullName", as: String.self, is: .init(validate: { fullNameStr in
            return FullNameValidator(fullNameStr: fullNameStr)
        }))
        validations.add("bankAccount", as: String.self, is: .init(validate: { ibanStr in
            return IBANValidator(ibanValueStr: ibanStr)
        }))
    }
}

// MARK: - UserBankAccountEntity + CreateUserBankAccountRequest
extension UserBankAccountEntity {
    convenience init(
        create request: CreateUserBankAccountRequest,
        bankId: BankEntity.IDValue?,
        userId: UserEntity.IDValue
    ) {
        self.init(bankID: bankId, userID: userId, holderFullName: request.fullName, bankAccount: request.bankAccount)
    }
}
