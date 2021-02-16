//
//  QuoteTagPivot.swift
//  
//
//  Created by hien.tran on 2/7/21.
//

import Fluent
import Foundation

final class QuoteTagPivot: Model {

    static let schema = "quote-tag-pivot"

    @ID
    var id: UUID?

    @Parent(key: "quoteID")
    var quote: Quote

    @Parent(key: "tagID")
    var tag: Tag

    init() {}

    init(
        id: UUID? = nil,
        quote: Quote,
        tag: Tag
    ) throws {
        self.id = id
        self.$quote.id = try quote.requireID()
        self.$tag.id = try tag.requireID()
    }
}
