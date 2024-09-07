//
//  EmailTokenRepository.swift
//
//
//  Created by Cemal on 3.09.2024.
//

import Vapor
import Fluent

// MARK: - EmailTokenRepository
protocol EmailTokenRepository: Repository {
    typealias EmailTokenDatabaseRepository = EmailTokenRepository & DatabaseRepository
    
    func find(token: String) async throws -> EmailTokenEntity?
    func create(_ emailToken: EmailTokenEntity) async throws
    func delete(_ emailToken: EmailTokenEntity) async throws
    func find(userID: UserEntity.IDValue) async throws -> EmailTokenEntity?
}
