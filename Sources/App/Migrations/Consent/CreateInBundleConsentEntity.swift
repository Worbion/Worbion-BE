//
//  CreateInBundleConsentEntity.swift
//
//
//  Created by Cemal on 28.08.2024.
//

import Fluent

// MARK: - CreateInBundleConsentEntity
struct CreateInBundleConsentEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(InBundleConsentEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("consent_id", .int64, .required, .references(
                ConsentEntity.schema, "id", onDelete: .cascade)
            )
            .field("consent_bundle_id", .int64, .required, .references(
                ConsentBundleEntity.schema, "id", onDelete: .cascade)
            )
            .unique(on: "consent_id", "consent_bundle_id")
            .field("is_required", .bool, .required)
            .field("confirmation_text", .string, .required)
            .field("confirmation_clickable_part_text", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(InBundleConsentEntity.schema).delete()
    }
}
