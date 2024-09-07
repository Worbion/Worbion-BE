//
//  CreateBankEntity.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Fluent

struct CreateBankEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(BankEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("bank_name", .string, .required)
            .field("bank_icon_url", .string, .required)
            .field("bank_iban_code", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(BankEntity.schema).delete()
    }
}

