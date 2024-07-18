import Fluent

struct CreateRefreshTokenEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(RefreshTokenEntity.schema)
            .id()
            .field("token", .string)
            .field("user_id", .uuid, .references("users", "id", onDelete: .cascade))
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
