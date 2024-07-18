import Fluent

struct CreateUserEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserEntity.schema)
            .id()
            .field("full_name", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("user_role", .string, .required)
            .field("is_email_verified", .bool, .required, .custom("DEFAULT FALSE"))
            .unique(on: "email")
            .field("created_at", .date, .required)
            .field("updated_at", .date, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(UserEntity.schema).delete()
    }
}
