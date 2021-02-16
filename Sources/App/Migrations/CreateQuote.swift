import Fluent
import Vapor

struct CreateQuote: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("quotes")
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .field("user-id", .uuid, .required, .references("users", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("quotes").delete()
    }
}

struct CreateQuoteData: Content {
  let short: String
  let long: String
  let userID: UUID
}
