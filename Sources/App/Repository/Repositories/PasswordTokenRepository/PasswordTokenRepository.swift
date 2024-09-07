//
//  PasswordTokenRepository.swift
//
//
//  Created by Cemal on 3.09.2024.
//

import Vapor
import Fluent

// MARK: - PasswordTokenRepository
protocol PasswordTokenRepository: Repository {
    typealias PasswordTokenDatabaseRepository = PasswordTokenRepository & DatabaseRepository
    
    func find(userID: UserEntity.IDValue) async throws -> PasswordTokenEntity?
    func find(token: String) async throws -> PasswordTokenEntity?
    func create(_ passwordToken: PasswordTokenEntity) async throws
    func delete(_ passwordToken: PasswordTokenEntity) async throws
    func delete(for userID: UserEntity.IDValue) async throws
}
