//
//  BankController.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor
import Fluent

// MARK: - BankController
struct BankController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("banks") { banks in
            banks.group(AdminAuthenticator()) { adminAuth in
                adminAuth.post(use: createBank)
                adminAuth.put(":bankId", use: updateBank)
                adminAuth.get(":bankId", use: getBank)
                adminAuth.delete(":bankId", use: deleteBank)
                adminAuth.put(":bankId", "icon", use: updateBankIcon)
            }
            
            banks.group(UserAuthenticator()) { userAuth in
                userAuth.get(use: getAllBanks)
            }
        }
    }
}

// MARK: - Bank Methods
extension BankController {
    @Sendable
    func createBank(request: Request) async throws -> BaseResponse<BankResponse> {
        try CreateBankRequest.validate(content: request)
    
        let createBankRequest = try request.content.decodeRequestContent(content: CreateBankRequest.self)
        
        // Upload bank icon
        guard let bankIconUrl = try await uploadBankIcon(request: request, icon: createBankRequest.bankIcon) else {
            let message = "Bank icon url is nil"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .internalServerError)
        }
        
        let bankEntity = BankEntity(create: createBankRequest, icon: bankIconUrl)
        
        try await bankEntity.save(on: request.db)
        
        return .success(data: bankEntity.mapBankResponse)
    }
    
    @Sendable
    func updateBank(request: Request) async throws -> BaseResponse<BankResponse> {
        try UpdateBankRequest.validate(content: request)
    
        let updateBankRequest = try request.content.decodeRequestContent(content: UpdateBankRequest.self)
        
        guard
            let bankId = request.parameters.get("bankId", as: Int64.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "bankId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        guard let bankEntity = try await BankEntity.find(bankId, on: request.db) else {
            let message = "Bank not found"
            throw GeneralError.generic(userMessage: message, systemMessage: message, status: .notFound)
        }
        
        bankEntity.bankName = updateBankRequest.bankName
        
        try await bankEntity.update(on: request.db)
        
        return .success(data: bankEntity.mapBankResponse)
    }
    
    @Sendable
    func updateBankIcon(request: Request) async throws -> BaseResponse<BankResponse> {
        try UpdateBankIconRequest.validate(content: request)
    
        let updateBankIconRequest = try request.content.decodeRequestContent(content: UpdateBankIconRequest.self)
        
        guard
            let bankId = request.parameters.get("bankId", as: Int64.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "bankId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        guard let bankEntity = try await BankEntity.find(bankId, on: request.db) else {
            let message = "Bank not found"
            throw GeneralError.generic(userMessage: message, systemMessage: message, status: .notFound)
        }
        
        guard let bankIconUrl = try await uploadBankIcon(request: request, icon: updateBankIconRequest.bankIcon) else {
            let message = "Bank icon url is nil"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .internalServerError)
        }
        
        bankEntity.iconUrl = bankIconUrl
        
        try await bankEntity.update(on: request.db)
        
        return .success(data: bankEntity.mapBankResponse)
    }
    
    @Sendable
    func getAllBanks(request: Request) async throws -> BaseResponse<[BankResponse]> {
        let bankEntities = try await BankEntity.query(on: request.db).all()
        let response = bankEntities.compactMap { $0.mapBankResponse }
        return .success(data: response)
    }
    
    @Sendable
    func deleteBank(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        guard
            let bankId = request.parameters.get("bankId", as: Int64.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "bankId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        try await BankEntity.query(on: request.db)
            .filter(\.$id == bankId)
            .delete()
        
        return .success()
    }
    
    @Sendable
    func getBank(request: Request) async throws -> BaseResponse<BankEntity> {
        guard
            let bankId = request.parameters.get("bankId", as: Int64.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "bankId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        let bankEntity = try await BankEntity.find(bankId, on: request.db)
        return .success(data: bankEntity)
    }
}

// MARK: - Private Util
private extension BankController {
    func uploadBankIcon(
        request: Request,
        icon: Data
    ) async throws -> String?
    {
        let uuid = UUID().uuidString
        let fileName = "banks/\(uuid).png"
        
        let uploadResult = try await request.storageHelper.uploadFile(
            fileData: icon,
            contentType: .image(format: .png),
            fileName: fileName
        )
        return uploadResult.mediaLink
    }
}
