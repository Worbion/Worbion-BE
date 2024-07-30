//
//  BankResponse.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - BankResponse
struct BankResponse: Content {
    let bankId: Int64?
    let bankName: String
    let bankIconUrl: String
}

// MARK: - BankEntity + BankResponse
extension BankEntity {
    var mapBankResponse: BankResponse {
        return .init(bankId: id, bankName: bankName, bankIconUrl: iconUrl)
    }
}
