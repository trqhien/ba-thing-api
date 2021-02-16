import Vapor
import Fluent

final class Quote: Model, Content {
    static let schema = "quotes"

    @Parent(key: "user-id")
    var user: User

    @ID
    var id: UUID?

    @Field(key: "short")
    var short: String

    @Field(key: "long")
    var long: String

    @Siblings(
        through: QuoteTagPivot.self,
        from: \.$quote,
        to: \.$tag
    )
    var tags: [Tag]

    init() {}

    init(
        id: UUID? = nil,
        short: String,
        long: String,
        userID: User.IDValue
    ) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID
    }
}
