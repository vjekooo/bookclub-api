//
//  UserToken.swift
//  book
//
//  Created by Vjeko Ne Radi on 29.03.2025..
//

import Vapor
import Fluent

final class UserToken: Model, Content, @unchecked Sendable {
    static let schema = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var user: User

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "expires_at", on: .update)
    var expiresAt: Date?

    init() { }

    init(id: UUID? = nil, value: String, userID: User.IDValue, expiresAt: Date? = nil) {
        self.id = id
        self.value = value
        self.$user.id = userID
        self.expiresAt = expiresAt
    }
}
