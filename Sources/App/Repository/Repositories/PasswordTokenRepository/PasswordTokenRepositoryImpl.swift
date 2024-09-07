//
//  PasswordTokenRepositoryImpl.swift
//  
//
//  Created by Cemal on 3.09.2024.
//

import Fluent
import Vapor

// MARK: - PasswordTokenRepositoryImpl
struct PasswordTokenRepositoryImpl: PasswordTokenRepository.PasswordTokenDatabaseRepository {
    
    let database: Database
    
    func find(userID: UserEntity.IDValue) async throws -> PasswordTokenEntity? {
        return try await PasswordTokenEntity.query(on: database)
            .filter(\.$user.$id == userID)
            .first()
        
    }
    
    func find(token: String) async throws -> PasswordTokenEntity? {
        return try await PasswordTokenEntity.query(on: database)
            .filter(\.$token == token)
            .first()
    }
    
    func create(_ passwordToken: PasswordTokenEntity) async throws {
        try await passwordToken.save(on: database)
    }
    
    func delete(_ passwordToken: PasswordTokenEntity) async throws {
        try await passwordToken.delete(on: database)
    }
    
    func delete(for userID: UserEntity.IDValue) async throws {
        try await PasswordTokenEntity.query(on: database)
            .filter(\.$user.$id == userID)
            .delete()
    }
}

// MARK: - User Repository + Application
extension Application.Repositories {
    var passwordTokens: PasswordTokenRepository {
        guard let storage = storage.makePasswordTokenRepository else {
            fatalError("PasswordTokenRepository not configured")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (PasswordTokenRepository)) {
        storage.makePasswordTokenRepository = make
    }
}

