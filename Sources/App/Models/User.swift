//
//  User.swift
//  
//
//  Created by hien.tran on 2/3/21.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"

    @ID
    var id: UUID?

    @Field(key: "telegram_id")
    var telegramID: Int

    @Field(key: "first_name")
    var firstName: String

    @OptionalField(key: "last_name")
    var lastName: String?

    @OptionalField(key: "username")
    var username: String?

    @Children(for: \.$user)
    var quotes: [Quote]

    init() {}

    init(
        id: UUID? = nil,
        telegramID: Int,
        firstName: String,
        lastName: String?,
        username: String?
    ) {
        self.id = id
        self.telegramID = telegramID
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
    }
}
