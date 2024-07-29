//
//  CreateConsentEntity.swift
//  
//
//  Created by Cemal on 28.07.2024.
//

import Fluent

struct CreateConsentEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(ConsentEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("consent_name", .string, .required)
            .unique(on: "consent_name")
            .field("consent_caption", .string, .required)
            .field("consent_type", .string, .required)
            .unique(on: "consent_type")
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(ConsentEntity.schema).delete()
    }
}

