//
//  Repository.swift
//
//
//  Created by Cemal on 2.09.2024.
//

import Vapor
import Fluent

// MARK: - Repository
protocol Repository {
    func `for`(_ req: Request) -> Self
}

// MARK: - DatabaseRepository
protocol DatabaseRepository: Repository {
    var database: Database { get }
    init(database: Database)
}

extension DatabaseRepository {
    func `for`(_ req: Request) -> Self {
        return Self.init(database: req.db)
    }
}
