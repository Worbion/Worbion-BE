//
//  CreateDeviceEntity.swift
//
//
//  Created by Cemal on 29.07.2024.
//

import Vapor
import Fluent

// MARK: - CreateDeviceEntity
struct CreateDeviceEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(DeviceEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("user_id", .int64, .references("users", "id", onDelete: .cascade))
            .field("device_unique_id", .string, .required)
            .field("push_token", .string, .required)
            .unique(on: "push_token")
            .field("device_os_Type", .string, .required)
            .unique(on: "device_unique_id", "device_os_Type")
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(DeviceEntity.schema).delete()
    }
}
