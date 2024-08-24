//
//  CreateUserAcceptedConsentEntity.swift
//
//
//  Created by Cemal on 24.08.2024.
//

import Fluent

// MARK: - CreateUserAcceptedConsentEntity
struct CreateUserAcceptedConsentEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserAcceptedConsentEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("user_id", .int64, .required, .references(
                UserEntity.schema, "id", onDelete: .cascade)
            )
            .field("consent_version", .int64, .required, .references(
                ConsentVersionEntity.schema, "id", onDelete: .cascade)
            )
            .unique(on: "user_id", "consent_version") // This fields combination should be unique
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(UserAcceptedConsentEntity.schema).delete()
    }
}

