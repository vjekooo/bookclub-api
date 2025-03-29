import Fluent
import FluentPostgresDriver
import Foundation

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
