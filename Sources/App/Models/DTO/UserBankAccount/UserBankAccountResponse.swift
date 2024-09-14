//
//  UserBankAccountResponse.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - UserBankAccountResponse
struct UserBankAccountResponse: Content {
    let id: Int64?
    let bank: BankResponse?
    let fullName: String
    let iban: String
}

// MARK: - UserBankAccountEntity + UserBankAccountResponse
extension UserBankAccountEntity {
    var mapToResponse: UserBankAccountResponse {
        return .init(
            id: id,
            bank: bank?.mapBankResponse,
            fullName: holderFullName,
            iban: bankAccount
        )
    }
}
