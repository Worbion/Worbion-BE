//
//  ConsentController.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor
import Fluent

// MARK: - ConsentController
struct ConsentController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("consents") { consents in
            consents.group(AdminAuthenticator()) { consents in
                // Fetch All Consents
                consents.get(use: getAllConsents(request:))
                // Create a consent
                consents.post(use: createConsent(request:))
                // Update a Consent
                consents.put(":id", use: updateConsent(request:))
                
                consents.group(":id", "versions") { version in
                    // Create Consent Version
                    version.post(use: createConsentVersion(request:))
                    // Get all versions of consent
                    /// consents/{consent_id}/versions -> get all consents
                    /// consents/{consent_id}/versions?version = 1.0 -> get just spesific version
                    version.get(use: getConsentVersions(request:))
                }
            }
            
            consents.group(UserAuthenticator()) { consents in
                // get latest version of consent by type
                /// consents?type=privacy_policy/latest-version
                consents.get("latest-version", use: getLastestVersionOfConsent(request:))
                // get all user visible consent types
                consents.get("types", use: getAllUserVisibleConsentTypes(request:))
            }
        }
    }
}

// MARK: - Consent Operations
private extension ConsentController {
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
    
    @Sendable
    func getAllConsents(request: Request) async throws -> BaseResponse<[ConsentEntity]> {
        let consents = try await ConsentEntity.query(on: request.db).all()
        return .success(data: consents)
    }
    
    @Sendable
    func getAllUserVisibleConsentTypes(request: Request) async throws -> BaseResponse<[ConsentType]> {
        let consents = ConsentType.allCases.filter { $0.isUserVisibleAgreementType }
        return .success(data: consents)
    }
}

// MARK: - Consent Version Operations
private extension ConsentController {
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
    func getLastestVersionOfConsent(request: Request) async throws -> BaseResponse<ConsentVersionResponse> {
        let consentType = try request.query.get(
            decodableType: ConsentType.self,
            at: "type"
        )
        
        let latestVersionOfConsent = try await ConsentVersionEntity.query(on: request.db)
            .join(parent: \ConsentVersionEntity.$consent)
            .filter(ConsentEntity.self, \.$consentType == consentType)
            .sort(\ConsentVersionEntity.$version, .descending)
            .first()

        guard
            let latestVersionOfConsent
        else {
            let message = "Consent version not found."
            let error = GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
            throw error
        }
        
        let response = ConsentVersionResponse(
            consentHtml: latestVersionOfConsent.htmlString,
            version: latestVersionOfConsent.version
        )
        
        return .success(data: response)
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
