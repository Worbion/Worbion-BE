import Fluent

struct CreateRefreshTokenEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(RefreshTokenEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("token", .string)
            .field("user_id", .int64, .references(UserEntity.schema, "id", onDelete: .cascade))
            .field("expires_at", .datetime)
            .field("issued_at", .datetime)
            .unique(on: "token")
            .unique(on: "user_id")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(RefreshTokenEntity.schema).delete()
    }
}
