//
//  UserBankAccountController.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor
import Fluent

// MARK: - UserBankAccountController
struct UserBankAccountController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("user-bank-accounts") { userBankAccounts in
            userBankAccounts.group(UserAuthenticator()) { userAuth in
                userAuth.post(use: createUserBankAccount)
                userAuth.put(":accountId", use: updateUserBankAccount(request:))
                userAuth.get(use: getAllUserBankAccounts)
                userAuth.get(":accountId", use: getUserBankAccount)
                userAuth.delete(":accountId", use: deleteUserBankAccount)
            }
        }
    }
}

// MARK: - Bank Methods
extension UserBankAccountController {
    @Sendable
    func createUserBankAccount(request: Request) async throws -> BaseResponse<Bool> {
        let payload = try request.auth.require(Payload.self)
        
        try CreateUserBankAccountRequest.validate(content: request)
        
        let createBankAccountRequest = try request.content.decodeRequestContent(content: CreateUserBankAccountRequest.self)
        
        guard let bank = try await BankEntity.find(createBankAccountRequest.bankId, on: request.db) else {
            let message = "Bank not found"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .notFound)
        }
        
        let bankAccount = UserBankAccountEntity(
            bankID: try bank.requireID(),
            userID: payload.userID,
            holderFullName: createBankAccountRequest.fullName,
            bankAccount: createBankAccountRequest.bankAccount
        )
        
        do {
            try await bankAccount.save(on: request.db)
        }catch {
            if let dbError = error as? DatabaseError, dbError.isConstraintFailure {
                let message = "This bank account already exist."
                let error = GeneralError.generic(userMessage: message, systemMessage: message, status: .conflict)
                throw error
            }
            throw error
        }
        return .success(data: true)
    }
    
    @Sendable
    func updateUserBankAccount(request: Request) async throws -> BaseResponse<Bool> {
        let payload = try request.auth.require(Payload.self)
        
        guard
            let bankAccountId = request.parameters.get("accountId", as: Int64.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "accountId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        try UpdateUserBankAccountRequest.validate(content: request)
        
        let updateBankAccountRequest = try request.content.decodeRequestContent(content: UpdateUserBankAccountRequest.self)

    
        // Get user bank account
        let userBankAccountEntity = try await UserBankAccountEntity.query(on: request.db)
            .filter(\.$id == bankAccountId)
            .filter(\.$user.$id == payload.userID)
            .first()
        
        guard let userBankAccountEntity else {
            let message = "No bank account founded"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .notFound)
        }
        
        // Check if needed update
        guard updateBankAccountRequest.updateFieldsIfNeeded(entity: userBankAccountEntity) else {
            let message = "No update needed. The fields are same"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .notFound)
        }
        
        // Get new bank from id
        guard let bank = try await BankEntity.find(updateBankAccountRequest.bankId, on: request.db) else {
            let message = "Bank not found."
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .notFound)
        }
        
        try await userBankAccountEntity.update(on: request.db)
        return .success(data: true)
    }
    
    @Sendable
    func deleteUserBankAccount(request: Request) async throws -> BaseResponse<Bool> {
        let payload = try request.auth.require(Payload.self)
        
        guard
            let bankAccountId = request.parameters.get("accountId", as: Int64.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "accountId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        let bankAccount = try await UserBankAccountEntity.query(on: request.db)
            .filter(\.$user.$id == payload.userID)
            .filter(\.$id == bankAccountId)
            .first()
        
        guard let bankAccount else {
            let message = "No bank account founded"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .notFound)
        }
        
        try await bankAccount.delete(on: request.db)
        
        return .success(data: true)
    }
    
    @Sendable
    func getUserBankAccount(request: Request) async throws -> BaseResponse<UserBankAccountResponse> {
        let payload = try request.auth.require(Payload.self)
        
        guard
            let bankAccountId = request.parameters.get("accountId", as: Int64.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "accountId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        let bankAccount = try await UserBankAccountEntity.query(on: request.db)
            .filter(\.$user.$id == payload.userID)
            .filter(\.$id == bankAccountId)
            .with(\.$bank)
            .first()
        
        guard let bankAccount else {
            let message = "No bank account founded"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .notFound)
        }
        let response = bankAccount.mapToResponse
        return .success(data: response)
    }
    
    @Sendable
    func getAllUserBankAccounts(request: Request) async throws -> BaseResponse<[UserBankAccountResponse]> {
        let payload = try request.auth.require(Payload.self)
        
        let bankAccounts = try await UserBankAccountEntity.query(on: request.db)
            .filter(\.$user.$id == payload.userID)
            .with(\.$bank)
            .all()
        
        let response = bankAccounts.compactMap { $0.mapToResponse }
        return .success(data: response)
    }
}
