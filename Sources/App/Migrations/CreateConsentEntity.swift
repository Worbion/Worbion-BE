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
            .field("consent_caption", .string, .required)
            .field("consent_version", .double, .required)
            .field("consent_url", .string, .required)
            .field("consent_type", .string, .required)
            .field("created_at", .date, .required)
            .field("updated_at", .date, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(ConsentEntity.schema).delete()
    }
}

