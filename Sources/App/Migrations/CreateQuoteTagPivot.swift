//
//  CreateQuoteTagPivot.swift
//  
//
//  Created by hien.tran on 2/7/21.
//

import Fluent

struct CreateQuoteTagPivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database
            .schema("quote-tag-pivot")
            .id()
            .field("quoteID", .uuid, .required, .references("quotes", "id", onDelete: .cascade))
            .field("tagID", .uuid, .required, .references("tags", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("quote-tag-pivot").delete()
    }
}
