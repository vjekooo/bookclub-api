//
//  UserBookClub.swift
//  book
//
//  Created by Vjeko Ne Radi on 28.03.2025..
//
import Vapor
import Fluent

final class UserBookClub: Model, @unchecked Sendable {
    static let schema = "user+book_club"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "book_club_id")
    var bookClub: BookClub

    init() { }

    init(id: UUID? = nil, user: User, bookClub: BookClub) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$bookClub.id = try bookClub.requireID()
    }
}
