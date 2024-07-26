//
//  CreateUserSocialEntity.swift
//  
//
//  Created by Cemal on 26.07.2024.
//

import Fluent

struct CreateUserSocialEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserSocialEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("user_id", .int64, .references(UserEntity.schema, "id", onDelete: .cascade))
            .field("social_id", .int64, .references(UserSocialEntity.schema, "id", onDelete: .cascade))
            .field("social_identifier", .string, .required)
            .field("created_at", .date, .required)
            .field("updated_at", .date, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(UserSocialEntity.schema).delete()
    }
}

