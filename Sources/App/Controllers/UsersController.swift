//
//  UsersController.swift
//  
//
//  Created by hien.tran on 2/3/21.
//

import Vapor
import Fluent

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("api", "users")
        usersRoute.post(use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(":userID", use: getHandler)
        usersRoute.get(":userID", "quotes", use: getQuotesHandler)
        usersRoute.get("telegram", ":userTelegramID", use: getHandlerByTelegramID)
        usersRoute.delete(":userID", use: removeUserHandler)
    }

    func createHandler(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user
            .save(on: req.db)
            .map { user }
    }

    func getAllHandler(_ req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }

    func getHandler(_ req: Request) throws -> EventLoopFuture<User> {
        return User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func getHandlerByTelegramID(_ req: Request) throws -> EventLoopFuture<User> {
        guard
            let telegramIDString = req.parameters.get("userTelegramID"),
            let telegramID = Int(telegramIDString)
        else {
            throw Abort(.notFound)
        }

        return User
            .query(on: req.db)
            .filter(\.$telegramID == telegramID)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    func getQuotesHandler(_ req: Request) throws -> EventLoopFuture<[Quote]> {
        return User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.$quotes.get(on: req.db)
            }

    }

    func removeUserHandler(_ req: Request) throws -> EventLoopFuture<User> {
        return User
            .find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user
                    .delete(on: req.db)
                    .map { user }
            }
    }
}
