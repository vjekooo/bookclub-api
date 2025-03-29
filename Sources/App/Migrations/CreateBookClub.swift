
import Fluent
import FluentPostgresDriver
import Foundation

struct CreateBookClub: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("book_clubs") 
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
         try await database.schema("book_clubs").delete()
    }
}
