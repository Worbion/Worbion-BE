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
    func createUserBankAccount(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        let payload = try request.auth.require(Payload.self)
        
        try CreateUserBankAccountRequest.validate(content: request)
        
        let createBankAccountRequest = try request.content.decodeRequestContent(content: CreateUserBankAccountRequest.self)
        
        
        guard let relatedBankCode = BankCodeParser.parse(from: createBankAccountRequest.bankAccount),
              let bankEntity = try await request.banks.find(relatedBankCode) else {
            let message = "user_banks.error.bank_not_found_by_iban"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        let userBankEntity = UserBankAccountEntity(
            create: createBankAccountRequest,
            bankId: try bankEntity.requireID(),
            userId: payload.userID
        )
        
        try await request.userBankAccounts.create(userBankEntity)
        return .success()
    }
    
    @Sendable
    func deleteUserBankAccount(request: Request) async throws -> BaseResponse<Bool> {
        let payload = try request.auth.require(Payload.self)
        
        guard let bankAccountId = request.parameters.get("accountId", as: UserBankAccountEntity.IDValue.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "accountId is missing or incorrect parameter.",
                status: .badRequest
            )
        }
        
        
        let bankAccount = try await request.userBankAccounts.getOne(bankAccountId, for: payload.userID)
        
        guard let bankAccount else {
            let message = "user_banks.error.no_user_bank_account_found"
            throw GeneralError.generic(userMessage: message, systemMessage: message, status: .notFound)
        }
        
        try await request.userBankAccounts.delete(bankAccount)
        
        return .success(data: true)
    }
    
    @Sendable
    func getUserBankAccount(request: Request) async throws -> BaseResponse<UserBankAccountResponse> {
        let payload = try request.auth.require(Payload.self)
        
        guard let bankAccountId = request.parameters.get("accountId", as: UserBankAccountEntity.IDValue.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "accountId is missing or incorrect parameter.",
                status: .badRequest
            )
        }
        
        guard let bankAccount = try await request.userBankAccounts.getOne(bankAccountId, for: payload.userID) else {
            let message = "user_banks.error.no_user_bank_account_found"
            throw GeneralError.generic(userMessage: message, systemMessage: message, status: .notFound)
        }
        let response = bankAccount.mapToResponse
        return .success(data: response)
    }
    
    @Sendable
    func getAllUserBankAccounts(request: Request) async throws -> BaseResponse<[UserBankAccountResponse]> {
        let payload = try request.auth.require(Payload.self)
        
        let bankAccounts = try await request.userBankAccounts.getAll(payload.userID)
        
        let response = bankAccounts.compactMap { $0.mapToResponse }
        return .success(data: response)
    }
}
