//
//  RefreshTokenRepository.swift
//
//
//  Created by Cemal on 3.09.2024.
//

import Vapor

// MARK: - RefreshTokenRepository
protocol RefreshTokenRepository: Repository {
    typealias RefreshTokenDatabaseRepository = DatabaseRepository & RefreshTokenRepository
    
    func create(_ token: RefreshTokenEntity) async throws
    func find(id: RefreshTokenEntity.IDValue?) async throws -> RefreshTokenEntity?
    func find(token: String) async throws -> RefreshTokenEntity?
    func delete(_ token: RefreshTokenEntity) async throws
    func delete(for userID: UserEntity.IDValue) async throws
}
