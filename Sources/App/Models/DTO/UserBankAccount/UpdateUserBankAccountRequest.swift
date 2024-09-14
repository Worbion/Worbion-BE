//
//  UpdateUserBankAccountRequest.swift
//
//
//  Created by Cemal on 31.07.2024.
//

import Vapor

// MARK: - UpdateUserBankAccountRequest
struct UpdateUserBankAccountRequest: Content, Equatable {
    let fullName: String
}

// MARK: - Validatable
extension UpdateUserBankAccountRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("fullName", as: String.self, is: .init(validate: { fullNameStr in
            return FullNameValidator(fullNameStr: fullNameStr)
        }))
    }
}

// MARK: - Fake Request
fileprivate extension UserBankAccountEntity {
    var fakeUpdateRequest: UpdateUserBankAccountRequest {
        return .init(fullName: holderFullName)
    }
}

// MARK: - Compare and update
extension UserBankAccountEntity {
    func updateFieldsIfNeeded(update request: UpdateUserBankAccountRequest) -> Bool {
        guard fakeUpdateRequest != request else {
            return false
        }
        holderFullName = request.fullName
        return true
    }
}
