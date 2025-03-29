import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) async throws {

    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: Environment.get("DB_HOST") ?? "localhost",
                username: Environment.get("DB_USER") ?? "book",
                password: Environment.get("DB_PASSWORD") ?? "admin123",
                database: Environment.get("DB_NAME") ?? "book-db",
                tls: .disable
            )
        ),
        as: .psql
    )

    app.migrations.add(
        CreateUser(),
        CreateBookClub(),
        CreateUserBookClub(),
        CreateUserToken()
    )

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)

    app.middleware.use(cors, at: .beginning)
    try routes(app)
}
