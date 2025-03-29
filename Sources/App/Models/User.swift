//
//  User.swift
//  book
//
//  Created by Vjeko Ne Radi on 27.03.2025..
//

import Fluent
import Vapor

final class User: Model, @unchecked Sendable, Authenticatable {
    // Name of the table or collection
    static let schema = "users"

    // Unique identifier for this user
    @ID(key: .id)
    var id: UUID?

    // The user's name
    @Field(key: "username")
    var username: String

    // Additional fields typically needed for users
    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    // Timestamps
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Siblings(through: UserBookClub.self, from: \.$user, to: \.$bookClub)
    var bookClubs: [BookClub]

    // Creates a new, empty User
    init() {}

    // Creates a new User with required properties
    init(id: UUID? = nil, username: String, email: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
    }
}
