//
//  UserRepository.swift
//
//
//  Created by Cemal on 2.09.2024.
//

import Vapor
import Fluent

// MARK: - UserRepository
protocol UserRepository: Repository {
    typealias UserDatabaseRepository = UserRepository & DatabaseRepository
    
    func create(_ user: UserEntity) async throws
    func find(_ userId: UserEntity.IDValue) async throws -> UserEntity?
    func find(_ email: String) async throws -> UserEntity?
    func update(_ user: UserEntity) async throws
    func set<Field>(_ field: KeyPath<UserEntity, Field>, to value: Field.Value, for userID: UserEntity.IDValue) async throws where Field: QueryableProperty, Field.Model == UserEntity
}
