//
//  ConsentController+Panel.swift
//
//
//  Created by Cemal on 24.08.2024.
//

import Vapor
import Fluent

// MARK: - ConsentController + Panel
extension ConsentController {
    func boot(panel routes: any RoutesBuilder) {
        // Fetch All Consents
        routes.get(use: getAllConsents(request:))
        // Create a consent
        routes.post(use: createConsent(request:))
        // Update a Consent
        routes.put(":id", use: updateConsent(request:))
        
        routes.group(":id", "versions") { version in
            // Create Consent Version
            version.post(use: createConsentVersion(request:))
            // Get all versions of consent
            /// consents/{consent_id}/versions -> get all consents
            /// consents/{consent_id}/versions?version = 1.0 -> get just spesific version
            version.get(use: getConsentVersions(request:))
        }
    }
}

// MARK: - Consent Methods
fileprivate extension ConsentController {
    @Sendable
    func getAllConsents(request: Request) async throws -> BaseResponse<[ConsentEntity]> {
        let consents = try await ConsentEntity.query(on: request.db).all()
        return .success(data: consents)
    }
    
    @Sendable
    func createConsent(request: Request) async throws -> BaseResponse<Int64> {
        
        try ConsentCreateRequest.validate(content: request)
        
        let consentCreateRequest = try request.content.decodeRequestContent(content: ConsentCreateRequest.self)
        
        let newConsent = ConsentEntity(create: consentCreateRequest)
        do {
            try await newConsent.save(on: request.db)
        }catch {
            if let dbError = error as? DatabaseError, dbError.isConstraintFailure {
                let message = "This consent type has already a consent. You cant create again. Please create a new version for this consent."
                let error = GeneralError.generic(userMessage: message, systemMessage: message, status: .conflict)
                throw error
            }
            throw error
        }
        let newConsentId = try newConsent.requireID()
        return .success(data: newConsentId)
    }
    
    @Sendable
    func updateConsent(request: Request) async throws -> BaseResponse<Bool> {
        guard
            let consentId = request.parameters.get("id", as: Int64.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "ConsentId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        try ConsentUpdateRequest.validate(content: request)
        
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

// MARK: - Consent Version Methods
fileprivate extension ConsentController {
    @Sendable
    func createConsentVersion(request: Request) async throws -> BaseResponse<Int64> {
        // Get ConsentId
        guard
            let consentId = request.parameters.get("id", as: Int64.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "ConsentId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        try CreateConsentVersionRequest.validate(content: request)
        
        let createConsentVersionRequest = try request.content.decodeRequestContent(content: CreateConsentVersionRequest.self)
        
        // Fetch consent
        guard
            let consent = try await ConsentEntity.find(consentId, on: request.db)
        else {
            let message = "The Consent you want to create new version not found."
            let error = GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
            throw error
        }
                
        let versionEntity = ConsentVersionEntity(
            create: createConsentVersionRequest,
            consentId: consentId
        )
        
        do {
            try await consent.$versions.create(versionEntity, on: request.db)
        }catch {
            if let dbError = error as? DatabaseError, dbError.isConstraintFailure {
                let message = "This consent version is already exist. Please change the version."
                let error = GeneralError.generic(userMessage: message, systemMessage: message, status: .conflict)
                throw error
            }
            throw error
        }
        
        let newVersionId = try versionEntity.requireID()
        
        return .success(data: newVersionId)
    }
    
    @Sendable
    func getConsentVersions(request: Request) async throws -> BaseResponse<[ConsentVersionXLResponse]> {
        guard
            let consentId = request.parameters.get("id", as: Int64.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "ConsentId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        var versionQuery = ConsentVersionEntity.query(on: request.db)
            .filter(\.$consent.$id == consentId)
        
        let requestedVersion = try? request.query.get(
            decodableType: Double.self,
            at: "version"
        )
        
        if let requestedVersion {
            versionQuery.filter(\.$version == requestedVersion)
        }
        
        let versions = try await versionQuery.all()
        
        let response = versions.compactMap { $0.mapConsentVersionXLResponse }
        return .success(data: response)
    }
}

