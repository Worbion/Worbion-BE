//
//  UpdateUserBankAccountRequest.swift
//
//
//  Created by Cemal on 31.07.2024.
//

import Vapor

// MARK: - UpdateUserBankAccountRequest
struct UpdateUserBankAccountRequest: Content {
    let bankId: BankEntity.IDValue
    let fullName: String
    let bankAccount: String
}

// MARK: - Validatable
extension UpdateUserBankAccountRequest: Validatable {
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

extension UpdateUserBankAccountRequest {
    func updateFieldsIfNeeded(entity: UserBankAccountEntity) -> Bool {
        if bankId != entity.$bank.$id.value ||
           fullName != entity.holderFullName ||
           bankAccount != entity.bankAccount 
        {
            entity.$bank.$id.value = bankId
            entity.holderFullName = fullName
            entity.bankAccount = bankAccount
            return true
        }
        return false
    }
}
