import Fluent

struct CreateUserEntity: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserEntity.schema)
            .field("id", .int64, .identifier(auto: true))
            .field("name", .string, .required)
            .field("surname", .string, .required)
            .field("phone_number", .string)
            .field("photo_url", .string)
            .field("bio", .string)
            .field("is_corporate", .bool, .required, .custom("DEFAULT FALSE"))
            .field(
                "created_by", .int64, .references(UserEntity.schema, "id", onDelete: .setNull)
            )
            .field("instagram_identifier", .string)
            .field("tiktok_identifier", .string)
            .field("x_identifier", .string)
            .field("website_url", .string)
            .field("password_hash", .string, .required)
            .field("user_role", .string, .required)
            .field(
                "is_email_verified", .bool, .required, .custom("DEFAULT FALSE")
            )
            .field("email", .string, .required)
            .unique(on: "email")
            .field("username", .string, .required)
            .unique(on: "username")
            .field("created_at", .date, .required)
            .field("updated_at", .date, .required)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(UserEntity.schema).delete()
    }
}
