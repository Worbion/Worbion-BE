//
//  UserBankAccountRepositoryImpl.swift
//  
//
//  Created by Cemal on 8.09.2024.
//

import Fluent
import Vapor

// MARK: - UserBankAccountRepositoryImpl
struct UserBankAccountRepositoryImpl: UserBankAccountRepository.UserBankAccountDatabaseRepository {
    
    let database: Database
    
    func create(_ userBankAccount: UserBankAccountEntity) async throws {
        try await userBankAccount.save(on: database)
    }
    
    func update(_ userBankAccount: UserBankAccountEntity) async throws {
        try await userBankAccount.update(on: database)
    }
    
    func delete(_ userBankAccount: UserBankAccountEntity) async throws {
        try await userBankAccount.delete(on: database)
    }
    
    func getOne(_ id: UserBankAccountEntity.IDValue, for userId: UserEntity.IDValue?) async throws -> UserBankAccountEntity? {
        let bankAccountQuery = UserBankAccountEntity.query(on: database)
        
        bankAccountQuery.filter(\.$id == id)
        
        if let userId {
            bankAccountQuery.filter(\.$user.$id == userId)
        }
        bankAccountQuery.with(\.$bank)

        return try await bankAccountQuery.first()
    }
    
    func getAll(_ userId: UserEntity.IDValue) async throws -> [UserBankAccountEntity] {
        let bankAccountsQuery = UserBankAccountEntity.query(on: database)
        
        bankAccountsQuery.filter(\.$user.$id == userId)
        
        return try await bankAccountsQuery.all()
    }
}

// MARK: - UserBankAccountRepository + Application
extension Application.Repositories {
    var userBankAccounts: UserBankAccountRepository {
        guard let storage = storage.makeUserBankAccountRepository else {
            fatalError("UserBankAccountRepository not configured")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (UserBankAccountRepository)) {
        storage.makeUserBankAccountRepository = make
    }
}

