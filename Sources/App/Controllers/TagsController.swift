//
//  TagsController.swift
//  
//
//  Created by hien.tran on 2/7/21.
//

import Vapor

final class TagsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tagsRoute = routes.grouped("api", "tags")

        tagsRoute.post(use: createHandler)
        tagsRoute.get(use: getAllHandler)
        tagsRoute.get(":tagID", use: getHandler)
        tagsRoute.get(":tagID", "quotes", use: getQuotesHandler)
    }

    func createHandler(_ req: Request) throws -> EventLoopFuture<Tag> {
        let tag = try req.content.decode(Tag.self)
        return tag.save(on: req.db).map { tag }
    }

    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Tag]> {
        return Tag.query(on: req.db).all()
    }

    func getHandler(_ req: Request) throws -> EventLoopFuture<Tag> {
        return Tag
            .find(req.parameters.get("tagID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func getQuotesHandler(_ req: Request) throws -> EventLoopFuture<[Quote]> {
        return Tag
            .find(req.parameters.get("tagID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { tag in
                tag.$quotes.get(on: req.db)
            }
    }
}
