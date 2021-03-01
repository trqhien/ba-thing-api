//
//  QuotesController.swift
//  
//
//  Created by hien.tran on 2/1/21.
//

import Vapor
import Fluent

struct QuotesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let quotesRoutes = routes.grouped("api", "quotes")
        quotesRoutes.get(use: getAllHandler)
        quotesRoutes.post(use: createHandler)
        quotesRoutes.put(":quoteID", use: updateHandler)
        quotesRoutes.get(":quoteID", use: getHandler)
        quotesRoutes.get("search", use: searchHandler)
        quotesRoutes.get("first", use: getFirstHandler)
        quotesRoutes.get("sorted", use: sortedHandler)
        quotesRoutes.get(":quoteID", "user", use: getUserHandler)
        quotesRoutes.post(":quoteID", "tags", ":tagID", use: addTagsHandler)
        quotesRoutes.get(":quoteID", "tags", use: getTagsHandler)
        quotesRoutes.delete(":quoteID", "tags", ":tagID", use: removeTagsHandler)
    }

    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[Quote]> {
        Quote.query(on: req.db).all()
    }

    func createHandler(_ req: Request) throws -> EventLoopFuture<Quote> {
        let data = try req.content.decode(CreateQuoteData.self)
        let quote = Quote(
            short: data.short,
            long: data.long,
            userID: data.userID
        )

        return quote
            .save(on: req.db)
            .map { quote }
    }

    func getHandler(_ req: Request) throws -> EventLoopFuture<Quote> {
        Quote
            .find(req.parameters.get("quoteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func updateHandler(_ req: Request) throws -> EventLoopFuture<Quote> {
        let updateData = try req.content.decode(CreateQuoteData.self)

        return Quote
            .find(req.parameters.get("quoteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { quote in
                quote.short = updateData.short
                quote.long = updateData.long
                quote.$user.id = updateData.userID
                return quote.save(on: req.db).map { quote }
            }
    }

    func deleteHandler(req: Request) throws -> EventLoopFuture<Quote> {
        Quote
            .find(req.parameters.get("quoteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { quote in
                quote.delete(on: req.db).map { quote }
            }
    }

    func searchHandler(req: Request) throws -> EventLoopFuture<[Quote]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }

        return Quote
            .query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short, .contains(inverse: false, .anywhere), searchTerm)
                or.filter(\.$short, .contains(inverse: false, .anywhere), searchTerm.lowercased())
                or.filter(\.$short, .contains(inverse: false, .anywhere), searchTerm.uppercased())
                or.filter(\.$short, .contains(inverse: false, .anywhere), searchTerm.capitalized)
                or.filter(\.$long, .contains(inverse: false, .anywhere), searchTerm)
                or.filter(\.$long, .contains(inverse: false, .anywhere), searchTerm.lowercased())
                or.filter(\.$long, .contains(inverse: false, .anywhere), searchTerm.uppercased())
                or.filter(\.$long, .contains(inverse: false, .anywhere), searchTerm.capitalized)
            }
            .all()
    }

    func getFirstHandler(req: Request) throws -> EventLoopFuture<Quote> {
        return Quote
            .query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    func sortedHandler(req: Request) throws -> EventLoopFuture<[Quote]> {
        Quote
            .query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }

    func getUserHandler(_ req: Request) throws -> EventLoopFuture<User> {
        return Quote
            .find(req.parameters.get("quoteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { quote in
                quote.$user.get(on: req.db)
            }
    }

    func addTagsHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let quoteQuery = Quote
            .find(req.parameters.get("quoteID"), on: req.db)
            .unwrap(or: Abort(.notFound))

        let tagQuery = Tag
            .find(req.parameters.get("tagID"), on: req.db)
            .unwrap(or: Abort(.notFound))

        return quoteQuery
            .and(tagQuery)
            .flatMap { quote, tag in
                quote
                    .$tags
                    .attach(tag, on: req.db)
                    .transform(to: .created)
            }
    }

    func getTagsHandler(_ req: Request) throws -> EventLoopFuture<[Tag]> {
        return Quote
            .find(req.parameters.get("quoteID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { quote in
                quote.$tags.query(on: req.db).all()
            }
    }

    func removeTagsHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let quoteQuery = Quote
            .find(req.parameters.get("quoteID"), on: req.db)
            .unwrap(or: Abort(.notFound))

        let tagQuery = Tag
            .find(req.parameters.get("tagID"), on: req.db)
            .unwrap(or: Abort(.notFound))

        return quoteQuery
            .and(tagQuery)
            .flatMap { quote, tag in
                quote.$tags
                    .detach(tag, on: req.db)
                    .transform(to: .noContent)
            }
    }
}
