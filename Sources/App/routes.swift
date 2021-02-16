import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: QuotesController())
    try app.register(collection: UsersController())
    try app.register(collection: TagsController())
}
