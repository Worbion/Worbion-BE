//
//  BankRepository.swift
//
//
//  Created by Cemal on 7.09.2024.
//

import Vapor
import Fluent

// MARK: - BankRepository
protocol BankRepository: Repository {
    typealias BankDatabaseRepository = BankRepository & DatabaseRepository
    
    func find(_ id: BankEntity.IDValue) async throws -> BankEntity?
    func find(_ bankCode: String) async throws -> BankEntity?
    func create(_ bank: BankEntity) async throws
    func all() async throws -> [BankEntity]
    func delete(_ id: BankEntity.IDValue) async throws
    func update(_ bank: BankEntity) async throws
    func set<Field>(_ field: KeyPath<BankEntity, Field>, to value: Field.Value, for bankId: BankEntity.IDValue) async throws where Field: QueryableProperty, Field.Model == BankEntity
}
