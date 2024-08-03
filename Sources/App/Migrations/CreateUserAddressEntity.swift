//
//  CreateUserAddressEntity.swift
//
//
//  Created by Cemal on 3.08.2024.
//

import Fluent

struct CreateUserAddressEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserAddressEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("user_id", .int64, .references(UserEntity.schema, "id", onDelete: .cascade))
            .field("address_holder_name", .string, .required)
            .field("address_holder_surname", .string, .required)
            .field("address_provience_id", .int64, .required)
            .field("address_district_id", .int64, .required)
            .field("address_neighbourhood_id", .int64, .required)
            .field("address_holder_phone", .string, .required)
            .field("address_title", .string, .required)
            .field("address_direction", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(UserAddressEntity.schema).delete()
    }
}
