import Fluent

struct CreatePasswordTokenEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(PasswordTokenEntity.schema)
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("token", .string, .required)
            .field("expires_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(PasswordTokenEntity.schema).delete()
    }
}
