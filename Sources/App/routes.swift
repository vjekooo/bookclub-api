import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: AuthController())
    try app.register(collection: UserController())

    app.get { req async in
        "It works!"
    }

}
