import Fluent
import Vapor

struct CreateUserBookClub: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("user+book_club")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("book_club_id", .uuid, .required, .references("book_clubs", "id", onDelete: .cascade))
            .unique(on: "user_id", "book_club_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("user+book_club").delete()
    }
}