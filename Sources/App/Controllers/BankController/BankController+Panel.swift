//
//  BankController+Panel.swift
//
//
//  Created by Cemal on 7.09.2024.
//

import Vapor
import Fluent

// MARK: - BankController + Panel
extension BankController {
    func boot(panel routes: any RoutesBuilder) {
        routes.group(AdminAuthenticator()) { adminAuth in
            adminAuth.get(use: getAll)
            adminAuth.post(use: createBank)
            adminAuth.put(":bankId", use: updateBank)
            adminAuth.get(":bankId", use: getBank)
            adminAuth.delete(":bankId", use: deleteBank)
            adminAuth.put(":bankId", "icon", use: updateBankIcon)
        }
    }
}

// MARK: - Methods
fileprivate extension BankController {
    @Sendable
    func getAll(request: Request) async throws -> BaseResponse<[BankEntity]> {
        let banks = try await request.banks.all()
        return .success(data: banks)
    }
    
    @Sendable
    func createBank(request: Request) async throws -> BaseResponse<BankEntity> {
        try CreateBankRequest.validate(content: request)
    
        let createBankRequest = try request.content.decodeRequestContent(content: CreateBankRequest.self)
        
        guard let bankIconUrl = try await uploadBankIcon(request: request, icon: createBankRequest.bankIcon) else {
            let message = "Bank icon url is nil"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .internalServerError)
        }
        
        let bankEntity = BankEntity(create: createBankRequest, icon: bankIconUrl)
        
        try await request.banks.create(bankEntity)
    
        return .success(data: bankEntity)
    }
    
    @Sendable
    func updateBank(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        try UpdateBankRequest.validate(content: request)
    
        let updateBankRequest = try request.content.decodeRequestContent(content: UpdateBankRequest.self)
        
        guard let bankId = request.parameters.get("bankId", as: BankEntity.IDValue.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "bankId is missing or incorrect parameter.",
                status: .badRequest
            )
        }
        
        guard let bankEntity = try await request.banks.find(bankId) else {
            let message = "bank not found"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
        }
        
        guard bankEntity.updateFieldsIfNeeded(update: updateBankRequest) else {
            let message = "fields are same"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
        }
        
        try await request.banks.update(bankEntity)
        
        return .success()
    }
    
    @Sendable
    func updateBankIcon(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        try UpdateBankIconRequest.validate(content: request)
    
        let updateBankIconRequest = try request.content.decodeRequestContent(content: UpdateBankIconRequest.self)
        
        guard let bankId = request.parameters.get("bankId", as: BankEntity.IDValue.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "bankId is missing or incorrect parameter.",
                status: .badRequest
            )
        }

        guard let bankIconUrl = try await uploadBankIcon(request: request, icon: updateBankIconRequest.bankIcon) else {
            let message = "Bank icon url is nil"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .internalServerError)
        }
        
        try await request.banks.set(\.$iconUrl, to: bankIconUrl, for: bankId)
        
        return .success()
    }
    
    @Sendable
    func deleteBank(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        guard let bankId = request.parameters.get("bankId", as: BankEntity.IDValue.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "bankId is missing or incorrect parameter.",
                status: .badRequest
            )
        }
        
        try await request.banks.delete(bankId)
        
        return .success()
    }
    
    @Sendable
    func getBank(request: Request) async throws -> BaseResponse<BankEntity> {
        guard let bankId = request.parameters.get("bankId", as: BankEntity.IDValue.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "bankId is missing or incorrect parameter.",
                status: .badRequest
            )
        }
        
        let bankEntity = try await request.banks.find(bankId)
        return .success(data: bankEntity)
    }
}

// MARK: - Private Util
fileprivate extension BankController {
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

