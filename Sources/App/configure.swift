import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    if let url = Environment.get("DATABASE_URL") {
        app.databases.use( try .postgres(url: url), as: .psql)
    } else {
        let databaseName: String
        let databasePort: Int

        if app.environment == .testing {
            databaseName = "vapor_test"
            if let testPort = Environment.get("DATABASE_PORT") {
                databasePort = Int(testPort) ?? 5433
            } else {
                databasePort = 5433
            }
        } else {
            databaseName = "vapor_database"
            databasePort = 5432
        }

        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: databasePort,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: databaseName
        ), as: .psql)
    }




    app.migrations.add(CreateUser())
    app.migrations.add(CreateQuote())
    app.migrations.add(CreateTag())
    app.migrations.add(CreateQuoteTagPivot())

    app.logger.logLevel = .debug
    try app.autoMigrate().wait()

    try routes(app)
}
