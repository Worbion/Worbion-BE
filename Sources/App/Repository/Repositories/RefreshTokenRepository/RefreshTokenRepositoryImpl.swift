//
//  RefreshTokenRepositoryImpl.swift
//  
//
//  Created by Cemal on 3.09.2024.
//

import Fluent
import Vapor

// MARK: - RefreshTokenRepositoryImpl
struct RefreshTokenRepositoryImpl: RefreshTokenRepository.RefreshTokenDatabaseRepository {
    
    let database: Database
    
    func create(_ token: RefreshTokenEntity) async throws {
        try await token.save(on: database)
    }
    
    func find(id: RefreshTokenEntity.IDValue?) async throws -> RefreshTokenEntity? {
        return try await RefreshTokenEntity.find(id, on: database)
    }
    
    func find(token: String) async throws -> RefreshTokenEntity? {
        let queryBuilder = RefreshTokenEntity.query(on: database)
        
        return try await queryBuilder.with(\.$user)
            .filter(\.$token == token)
            .first()
    }
    
    func delete(_ token: RefreshTokenEntity) async throws {
        try await token.delete(on: database)
    }
    
    func delete(for userID: UserEntity.IDValue) async throws {
        try await RefreshTokenEntity.query(on: database)
            .filter(\.$user.$id == userID)
            .delete()
    }
}

// MARK: - User Repository + Application
extension Application.Repositories {
    var refreshTokens: RefreshTokenRepository {
        guard let storage = storage.makeRefreshTokenRepository else {
            fatalError("RefreshTokenRepository not configured")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (RefreshTokenRepository)) {
        storage.makeRefreshTokenRepository = make
    }
}

