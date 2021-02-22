//
//  CreateUser.swift
//  
//
//  Created by hien.tran on 2/3/21.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("telegram_id", .int, .required)
            .field("first_name", .string, .required)
            .field("last_name", .string)
            .field("username", .string)
            .unique(on: "telegram_id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
