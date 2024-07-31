//
//  CreateUserBankAccountEntity.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Fluent

struct CreateUserBankAccountEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserBankAccountEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("bank_id", .int64, .references(BankEntity.schema, "id", onDelete: .cascade))
            .field("user_id", .int64, .references(UserEntity.schema, "id", onDelete: .cascade))
            .field("holder_full_name", .string, .required)
            .field("bank_account", .string, .required)
            .unique(on: "bank_account")
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(UserBankAccountEntity.schema).delete()
    }
}


