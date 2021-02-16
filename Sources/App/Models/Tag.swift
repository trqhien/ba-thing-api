//
//  Tag.swift
//  
//
//  Created by hien.tran on 2/7/21.
//

import Fluent
import Vapor

final class Tag: Model, Content {
    static let schema = "tags"

    @ID
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Siblings(
        through: QuoteTagPivot.self,
        from: \.$tag,
        to: \.$quote
    )
    var quotes: [Quote]

    init() {}

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
