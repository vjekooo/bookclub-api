//
//  UserController.swift
//  book
//
//  Created by Vjeko Ne Radi on 29.03.2025..
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("user")
        
        // Public routes (no authentication required)
        users.post(use: create)
        
        // Protected routes requiring authentication would go here
        // let protected = users.grouped([Authentication Middleware])
        // protected.put(":userID", use: update)
        // protected.delete(":userID", use: delete)
    }
    
    // Create a new user
    func create(req: Request) async throws -> User.Public {
        // Typically you'd use a DTO (Data Transfer Object) here
        let user  = try req.content.decode(CreateUserRequest.self)
        
        // Hash the password
        let passwordHash = try await req.password.async.hash(user.password)
        
        // Create a new user model
        let newUser = User(
            username: user.username,
            email: user.email,
            passwordHash: passwordHash
        )
        
        // Save to database
        try await newUser.save(on: req.db)
        return User.Public(id: newUser.id!, username: newUser.username, email: newUser.email)

    }
}

struct CreateUserRequest: Content {
    let username: String
    let email: String
    let password: String
}

struct UpdateUserRequest: Content {
    let username: String?
    let email: String?
    let password: String?
}

extension User {
    struct Public: Content {
        let id: UUID
        let username: String
        let email: String
    }
}
