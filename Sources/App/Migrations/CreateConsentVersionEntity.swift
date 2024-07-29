//
//  CreateConsentVersionEntity.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Fluent

// MARK: - CreateConsentVersionEntity
struct CreateConsentVersionEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(ConsentVersionEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("consent_id", .int64, .required, .references("consents", "id", onDelete: .cascade))
            .field("consent_version", .double, .required)
            .unique(on: "consent_id", "consent_version") // This fields combination should be unique
            .field("consent_url", .string, .required)
            .field("created_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(ConsentVersionEntity.schema).delete()
    }
}
