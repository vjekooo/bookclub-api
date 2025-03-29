//
//  BookClub.swift
//  book
//
//  Created by Vjeko Ne Radi on 28.03.2025..
//

import Fluent
import Vapor

final class BookClub: Model, @unchecked Sendable {
    static let schema: String = "book_clubs"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "readers_count")
    var readersCount: Int

    @Field(key: "max_readers")
    var maxReaders: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Siblings(through: UserBookClub.self, from: \.$bookClub, to: \.$user)
    var users: [User]

    init() {}

    init(id: UUID? = nil, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}
