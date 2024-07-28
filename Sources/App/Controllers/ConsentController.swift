//
//  ConsentController.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor
import Fluent

struct ConsentController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("consent") { user in
            user.group(AdminAuthenticator()) { authenticated in
                authenticated.post(use: createConsent(request:))
                authenticated.put(":id", use: updateConsent(request:))
            }
        }
    }
}

private extension ConsentController {
    @Sendable
    func createConsent(request: Request) async throws -> BaseResponse<ConsentCreateResponse> {
        
        try ConsentCreateRequest.validate(query: request)
        
        let consentCreateRequest = try request.content.decodeRequestContent(content: ConsentCreateRequest.self)
        
        // Is there exist version of consent
        let existConsent = try await ConsentEntity.query(on: request.db)
            .filter(\.$consentVersion == consentCreateRequest.consentVersion)
            .filter(\.$consentType == .enumCase(consentCreateRequest.consentType.rawValue))
            .first()
        
        guard
            existConsent == nil
        else {
            let message = "this content version of related consent type is already exist."
            let error = GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .conflict
            )
            throw error
        }
        
        let fileName = "consents/\(consentCreateRequest.consentName)/\(consentCreateRequest.consentVersion).pdf"
        
        let uploadConsentFileResult = try await request.storageHelper.uploadFile(
            fileData: consentCreateRequest.consentFile,
            contentType: .pdf,
            fileName: fileName
        )
        
        guard 
            let pdfLink = uploadConsentFileResult.mediaLink
        else {
            let message = "An Error occured while uploading pdf."
            let error = GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .internalServerError
            )
            throw error
        }
        
        let newConsent = ConsentEntity(
            create: consentCreateRequest,
            consent: pdfLink
        )
        
        try await newConsent.save(on: request.db)
        return .success(data: .init(consentId: newConsent.id))
    }
    
    @Sendable
    func updateConsent(request: Request) async throws -> BaseResponse<Bool> {
        guard
            let consentIdParameter = request.parameters.get("id"),
            let consentId = Int64(consentIdParameter)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "UserId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        try ConsentUpdateRequest.validate(query: request)
        
        let consentUpdateRequest = try request.content.decodeRequestContent(content: ConsentUpdateRequest.self)
        
        guard
            let consentEntity = try await ConsentEntity.find(consentId, on: request.db)
        else {
            let message = "Consent not found"
            let error = GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
            throw error
        }
        
        guard
            consentEntity.compareAndUpdateFieldsIfCanDo(with: consentUpdateRequest)
        else {
            let message = "Update failed. Fields are same."
            let error = GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
            throw error
        }
        
        try await consentEntity.update(on: request.db)
        
        return .success(data: true)
    }
}
