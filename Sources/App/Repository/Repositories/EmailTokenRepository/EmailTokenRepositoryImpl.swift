//
//  EmailTokenRepositoryImpl.swift
//
//
//  Created by Cemal on 3.09.2024.
//

import Fluent
import Vapor

// MARK: - EmailTokenRepositoryImpl
struct EmailTokenRepositoryImpl: EmailTokenRepository.EmailTokenDatabaseRepository {
    let database: Database
    
    func find(token: String) async throws -> EmailTokenEntity? {
        return try await EmailTokenEntity.query(on: database)
            .filter(\.$token == token)
            .first()
    }
    
    func create(_ emailToken: EmailTokenEntity) async throws {
        try await emailToken.save(on: database)
    }
    
    func delete(_ emailToken: EmailTokenEntity) async throws {
        try await emailToken.delete(on: database)
    }
    
    func find(userID: UserEntity.IDValue) async throws -> EmailTokenEntity? {
        return try await EmailTokenEntity.find(userID, on: database)
    }
}

// MARK: - User Repository + Application
extension Application.Repositories {
    var emailTokens: EmailTokenRepository {
        guard let storage = storage.makeEmailTokenRepository else {
            fatalError("EmailTokenRepository not configured")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (EmailTokenRepository)) {
        storage.makeEmailTokenRepository = make
    }
}




