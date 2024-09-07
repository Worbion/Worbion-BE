//
//  UserDatabaseRepositoryImpl.swift
//
//
//  Created by Cemal on 2.09.2024.
//

import Fluent
import Vapor

// MARK: - UserDatabaseRepositoryImpl
struct UserDatabaseRepositoryImpl: UserRepository.UserDatabaseRepository {
    func find(_ email: String) async throws -> UserEntity? {
        return try await UserEntity.query(on: database)
            .filter(\.$email == email)
            .first()
    }
    
    
    let database: Database
    
    func create(_ user: UserEntity) async throws {
        try await user.save(on: database)
    }
    
    func find(_ userId: UserEntity.IDValue) async throws -> UserEntity? {
        return try await UserEntity.find(userId, on: database)
    }
    
    func update(_ user: UserEntity) async throws {
        try await user.update(on: database)
    }
    
    func set<Field>(_ field: KeyPath<UserEntity, Field>, to value: Field.Value, for userID: UserEntity.IDValue) async throws where Field : FluentKit.QueryableProperty, Field.Model == UserEntity {
        return try await UserEntity.query(on: database)
            .filter(\.$id == userID)
            .set(field, to: value)
            .update()
    }
}

// MARK: - User Repository + Application
extension Application.Repositories {
    var users: UserRepository {
        guard let storage = storage.makeUserRepository else {
            fatalError("UserRepository not configured")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (UserRepository)) {
        storage.makeUserRepository = make
    }
}
