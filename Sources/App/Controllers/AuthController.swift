//
//  AuthController.swift
//  book
//
//  Created by Vjeko Ne Radi on 29.03.2025..
//

import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")

        auth.post("register", use: register)
        auth.post("login", use: login)

        let protected = auth.grouped(UserAuthenticator())
        protected.post("logout", use: logout)
    }

    func register(req: Request) async throws -> User.Public {
        try RegisterRequest.validate(content: req)
        let registerRequest = try req.content.decode(RegisterRequest.self)

        if try await User.query(on: req.db)
            .filter(\.$email == registerRequest.email)
            .first() != nil {
            throw Abort(.conflict, reason: "A user with this email already exists")
        }

        let passwordHash = try await req.password.async.hash(registerRequest.password)

        let user = User(
            username: registerRequest.username,
            email: registerRequest.email,
            passwordHash: passwordHash
        )

        try await user.save(on: req.db)

        return User.Public(
            id: user.id!,
            username: user.username,
            email: user.email
        )
    }

    func login(req: Request) async throws -> LoginResponse {
        try LoginRequest.validate(content: req)
        let loginRequest = try req.content.decode(LoginRequest.self)

        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginRequest.email)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }

        guard try await req.password.async.verify(
            loginRequest.password,
            created: user.passwordHash
        ) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }

        let token = try user.generateToken()
        try await token.save(on: req.db)

        return LoginResponse(
            user: User.Public(id: user.id!, username: user.username, email: user.email),
            token: token.value
        )
    }

    func logout(req: Request) async throws -> HTTPStatus {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }

        try await UserToken.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .delete()

        return .ok
    }
}

struct RegisterRequest: Content, Validatable {
    let username: String
    let email: String
    let password: String

    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

struct LoginRequest: Content, Validatable {
    let email: String
    let password: String

    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: !.empty)
    }
}

struct LoginResponse: Content {
    let user: User.Public
    let token: String
}

extension User {
    func generateToken() throws -> UserToken {
        let random = [UInt8].random(count: 32)
        let value = random.base64

        let calendar = Calendar.current
        let expiryDate = calendar.date(byAdding: .day, value: 30, to: Date())

        return UserToken(value: value, userID: self.id!, expiresAt: expiryDate)
    }
}

struct UserAuthenticator: AsyncBearerAuthenticator {
    typealias User = App.User

    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        guard let token = try await UserToken.query(on: request.db)
            .filter(\.$value == bearer.token)
            .with(\.$user)  // Eager load the associated user
            .first()
        else {
            return
        }

        if let expiresAt = token.expiresAt, expiresAt < Date() {
            try await token.delete(on: request.db)
            return
        }

        request.auth.login(token.user)
    }
}

extension RoutesBuilder {
    func protectedByBearer() -> any RoutesBuilder {
        return self.grouped(UserAuthenticator(), User.guardMiddleware())
    }
}

