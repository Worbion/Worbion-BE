//
//  UserBankAccountRepository.swift
//
//
//  Created by Cemal on 7.09.2024.
//

import Vapor
import Fluent

// MARK: - UserBankAccountRepository
protocol UserBankAccountRepository: Repository {
    typealias UserBankAccountDatabaseRepository = UserBankAccountRepository & DatabaseRepository
    
    func create(_ userBankAccount: UserBankAccountEntity) async throws
    func update(_ userBankAccount: UserBankAccountEntity) async throws
    func delete(_ userBankAccount: UserBankAccountEntity) async throws
    func getOne(_ id: UserBankAccountEntity.IDValue, for userId: UserEntity.IDValue?) async throws -> UserBankAccountEntity?
    func getAll(_ userId: UserEntity.IDValue) async throws -> [UserBankAccountEntity]
}

