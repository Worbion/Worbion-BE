//
//  CreateSocialEntity.swift
//
//
//  Created by Cemal on 26.07.2024.
//

import Fluent

struct CreateSocialEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(SocialEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("social_name", .string, .required)
            .field("socialIconUrl", .string, .required)
            .field("social_identifier_key_name", .string, .required)
            .field("social_identifier_replace_key", .string, .required)
            .field("social_profile_url_template", .string, .required)
            .field("created_at", .date, .required)
            .field("updated_at", .date, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(SocialEntity.schema).delete()
    }
}
