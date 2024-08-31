//
//  CreateConsentBundleEntity.swift
//
//
//  Created by Cemal on 28.08.2024.
//

import Fluent

// MARK: - CreateConsentBundleEntity
struct CreateConsentBundleEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(ConsentBundleEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("consent_bundle_type", .string, .required)
            .unique(on: "consent_bundle_type")
            .field("consent_bundle_name", .string, .required)
            .field("consent_bundle_description", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(ConsentBundleEntity.schema).delete()
    }
}

