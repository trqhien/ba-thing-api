//
//  File.swift
//  
//
//  Created by hien.tran on 2/7/21.
//

import Fluent

struct CreateTag: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tags")
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("tags").delete()
    }
}
