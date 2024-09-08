//
//  BankRepositoryImpl.swift
//  
//
//  Created by Cemal on 7.09.2024.
//

import Fluent
import Vapor

// MARK: - BankRepositoryImpl
struct BankRepositoryImpl: BankRepository.BankDatabaseRepository {
    
    let database: Database
    
    func find(_ id: BankEntity.IDValue) async throws -> BankEntity? {
        return try await BankEntity.find(id, on: database)
    }
    
    func create(_ bank: BankEntity) async throws {
        try await bank.save(on: database)
    }
    
    func update(_ bank: BankEntity) async throws {
        try await bank.update(on: database)
    }
    
    func all() async throws -> [BankEntity] {
        return try await BankEntity.query(on: database).all()
    }
    
    func delete(_ id: BankEntity.IDValue) async throws {
        try await BankEntity.query(on: database)
            .filter(\.$id == id)
            .delete()
    }
    
    func set<Field>(_ field: KeyPath<BankEntity, Field>, to value: Field.Value, for bankId: BankEntity.IDValue) async throws where Field : FluentKit.QueryableProperty, Field.Model == BankEntity {
        try await BankEntity.query(on: database)
            .filter(\.$id == bankId)
            .set(field, to: value)
            .update()
    }
}

// MARK: - Bank Repository + Application
extension Application.Repositories {
    var banks: BankRepository {
        guard let storage = storage.makeBankRepository else {
            fatalError("BankRepository not configured")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (BankRepository)) {
        storage.makeBankRepository = make
    }
}
