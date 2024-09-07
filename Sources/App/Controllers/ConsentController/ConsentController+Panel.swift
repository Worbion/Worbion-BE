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
        routes.get(use: getAllConsents)
        routes.post(use: createConsent)
        routes.put(":id", use: updateConsent)
        
        routes.group(":id", "versions") { version in
            version.post(use: createConsentVersion)
            version.get(use: getConsentVersions)
            version.put(":versionId", use: updateConsentVersion)
        }
        
        routes.group("bundles") { consentBundles in
            consentBundles.get(use: getAllConsentBundles)
            consentBundles.post(use: createConsentBundle)
            consentBundles.put(":bundleId", use: updateConsentBundle)
            consentBundles.delete(":bundleId", use: deleteConsentBundle)
        }
        
        routes.group("bundles", ":bundleId", "consent") { consentBundle in
            consentBundle.post(use: addConsentToBundle)
            consentBundle.delete(":consentId", use: deleteConsentFromBundle)
        }
    }
}

// MARK: - Consent Methods
fileprivate extension ConsentController {
    
    @Sendable
    /// Retrieves all consents in the database.
    /// - Returns: Consent list
    func getAllConsents(request: Request) async throws -> BaseResponse<[ConsentEntity]> {
        let consents = try await request.consents.all()
        return .success(data: consents)
    }
    
    @Sendable
    /// Creates a new consent. The consent type must be unique. Only different consents versions can be created for the same type of consent.
    /// - Returns: ConsentEntity.IDValue value that ID of the created consent.
    func createConsent(request: Request) async throws -> BaseResponse<ConsentEntity.IDValue> {
        
        try ConsentCreateRequestDTO.validate(content: request)
        
        let consentCreateRequest = try request.content.decodeRequestContent(content: ConsentCreateRequestDTO.self)
        
        let newConsent = ConsentEntity(create: consentCreateRequest)
        
        do {
            try await request.consents.create(newConsent)
        }catch {
            if error.isDBConstraintFailureError {
                let message = "This consent type has already exist. You cant create again."
                throw GeneralError.generic(
                    userMessage: message,
                    systemMessage: message,
                    status: .conflict
                )
            }
            throw error
        }
        
        let newConsentId = try newConsent.requireID()
        
        return .success(data: newConsentId)
    }
    
    @Sendable
    /// Updates fields for a consent record external to the consent type.
    /// - Returns: Bool value that  indicating whether the update operation was successful or not.
    func updateConsent(request: Request) async throws -> BaseResponse<Bool> {
        guard let consentId = request.parameters.get("id", as: ConsentEntity.IDValue.self) else {
            let message = "ConsentId is missing or incorrect parameter."
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        try ConsentUpdateRequestDTO.validate(content: request)
        
        let consentUpdateRequest = try request.content.decodeRequestContent(content: ConsentUpdateRequestDTO.self)
        
        guard let consentEntity = try await request.consents.find(consentId) else {
            let message = "Consent not found"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
        }
        
        guard consentEntity.compareAndUpdateFieldsIfCanDo(with: consentUpdateRequest) else {
            let message = "Fields are same."
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        try await request.consents.update(consentEntity)
        
        return .success(data: true)
    }
}

// MARK: - Consent Version Methods
fileprivate extension ConsentController {
    @Sendable
    /// Creates a new version of a consent.
    /// - Returns: ConsentVersionEntity.ID value of the created consent version.
    func createConsentVersion(request: Request) async throws -> BaseResponse<ConsentVersionEntity.IDValue> {
        guard let consentId = request.parameters.get("id", as: ConsentVersionEntity.IDValue.self) else {
            let message = "ConsentId is missing or incorrect parameter."
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        try CreateConsentVersionRequestDTO.validate(content: request)
        
        let createConsentVersionRequest = try request.content.decodeRequestContent(content: CreateConsentVersionRequestDTO.self)
        
        let versionEntity = ConsentVersionEntity(
            create: createConsentVersionRequest,
            consentId: consentId
        )
        
        try await request.consents.createVersion(versionEntity, for: consentId)
        
        let newVersionId = try versionEntity.requireID()
        
        return .success(data: newVersionId)
    }
    
    @Sendable
    /// Returns the requested version or versions of a consent.
    /// - Returns: ConsentVersionXLResponse Array for list of the requested consent version(s)
    /**
     Example:
     consents/{consent_id}/versions -> get all consents
     consents/{consent_id}/versions?version = 1.0 -> get just spesific version
     */
    func getConsentVersions(request: Request) async throws -> BaseResponse<[ConsentVersionXLResponseDTO]> {
        guard let consentId = request.parameters.get("id", as: ConsentEntity.IDValue.self) else {
            let message = "ConsentId is missing or incorrect parameter."
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }

        let requestedVersion = try? request.query.get(
            decodableType: Double.self,
            at: "version"
        )
        
        let versions = try await request.consents.getVersions(requestedVersion, for: consentId)
        let response = versions.compactMap { $0.mapConsentVersionXLResponse }
        return .success(data: response)
    }
    
    @Sendable
    /// Updates the fields of the consent version.
    /// - Returns: Bool value for indicates whether the update process was completed successfully or not.
    func updateConsentVersion(request: Request) async throws -> BaseResponse<Bool> {
        guard let consentVersionId = request.parameters.get("versionId", as: ConsentVersionEntity.IDValue.self) else {
            let message = "VersionId missing or incorrect parameter."
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        let updateConsentVersionRequest = try request.content.decodeRequestContent(content: UpdateConsentVersionRequestDTO.self)
                
        guard let versionEntity = try await request.consents.findVersion(consentVersionId) else {
            let message = "The version is not found. Please refresh your page."
            let error = GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
            throw error
        }
        
        guard versionEntity.compareAndUpdateIfNeeded(request: updateConsentVersionRequest) else {
            let message = "The fields are same."
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        try await request.consents.updateVersion(versionEntity)
        return .success(data: true)
    }
}

// MARK: - Consent Bundle Operations
fileprivate extension ConsentController {
    @Sendable
    /// Returns all consent bundles
    /// - Returns: ConsentBundleEntity Array
    func getAllConsentBundles(request: Request) async throws -> BaseResponse<[ConsentBundleEntity]> {
        let bundles = try await request.consents.getAllConsentBundles()
        return .success(data: bundles)
    }
    
    @Sendable
    /// Create a consent bundle
    /// - Returns: ConsentBundleEntity.IDValue of new consent bundle id
    func createConsentBundle(request: Request) async throws -> BaseResponse<ConsentBundleEntity.IDValue> {
        try CreateConsentBundleRequestDTO.validate(content: request)
        let createConsentBundleRequest = try request.content.decodeRequestContent(content: CreateConsentBundleRequestDTO.self)
        
        let consentBundleEntity = ConsentBundleEntity(request: createConsentBundleRequest)
        
        do {
            try await request.consents.createConsentBundle(consentBundleEntity)
        }catch {
            if error.isDBConstraintFailureError {
                let message = "This content bundle type is exist."
                throw GeneralError.generic(
                    userMessage: message,
                    systemMessage: message,
                    status: .conflict
                )
            }
        }
        let createdConsentBundleId = try consentBundleEntity.requireID()
        return .success(data: createdConsentBundleId)
    }
    
    @Sendable
    /// Update a consent bundle
    /// - Returns: Bool value to update operation is successfull or not.
    func updateConsentBundle(request: Request) async throws -> BaseResponse<Bool> {
        guard let bundleId = request.parameters.get("bundleId", as: ConsentBundleEntity.IDValue.self) else {
            let message = "BundleId required"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        try UpdateConsentBundleDTO.validate(content: request)
        
        let updateConsentBundleRequest = try request.content.decodeRequestContent(content: UpdateConsentBundleDTO.self)
        
        guard let consentBundleEntity = try await request.consents.findConsentBundle(bundleId) else {
            let message = "Consent bundle not found"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
        }
        
        guard consentBundleEntity.checkAndUpdateFieldsIfNeeded(request: updateConsentBundleRequest) else {
            let message = "The consent bundle fields same with your request. You cant update."
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        try await request.consents.updateConsentBundle(consentBundleEntity)
        
        return .success(data: true)
    }
    
    @Sendable
    /// Delete a consent bundle
    /// - Returns: Bool value to delete operation is successfull or not.
    func deleteConsentBundle(request: Request) async throws -> BaseResponse<Bool> {
        guard let bundleId = request.parameters.get("bundleId", as: ConsentBundleEntity.IDValue.self) else {
            let message = "BundleId required"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        try await request.consents.deleteConsentBundle(bundleId)
        
        return .success(data: true)
    }
}

// MARK: - InBundleConsent Operations
fileprivate extension ConsentController {
    @Sendable
    /// Add a consent into consent bundle
    /// - Returns: Bool value to add operation is successfull or not.
    func addConsentToBundle(request: Request) async throws -> BaseResponse<Bool> {
        guard let bundleId = request.parameters.get("bundleId", as: ConsentBundleEntity.IDValue.self) else {
            let message = "BundleId required"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        try AddConsentToBundleRequestDTO.validate(content: request)
        
        let addConsentToBundleRequestDTO = try request.content.decodeRequestContent(content: AddConsentToBundleRequestDTO.self)
        
        guard let consentBundleEntity = try await request.consents.findConsentBundle(bundleId) else {
            let message = "Consent bundle not found"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
        }
        
        let requestedConsentId = addConsentToBundleRequestDTO.consentId
        let consentEntity = try await request.consents.find(requestedConsentId)
        
        guard consentEntity != nil else {
            let message = "Consent not found"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
        }
        
        let inBundleConsent = InBundleConsentEntity(
            request: addConsentToBundleRequestDTO,
            bundleId: try consentBundleEntity.requireID()
        )
        
        do {
            try await request.consents.createInBundleConsent(inBundleConsent)
        }catch {
            if error.isDBConstraintFailureError {
                let message = "this bundle already has this consent. You cant add again."
                throw GeneralError.generic(
                    userMessage: message,
                    systemMessage: message,
                    status: .conflict
                )
            }
        }
        
        return .success(data: true)
    }
    
    @Sendable
    /// Delete a consent from consent bundle
    /// - Returns: Bool value to delete operation is successfull or not.
    func deleteConsentFromBundle(request: Request) async throws -> BaseResponse<Bool> {
        guard let bundleId = request.parameters.get("bundleId", as: ConsentBundleEntity.IDValue.self) else {
            let message = "BundleId required"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        guard let consentId = request.parameters.get("consentId", as: ConsentEntity.IDValue.self) else {
            let message = "ConsentId required"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        try await request.consents.deleteInBundleConsent(consentId, bundleId)
        
        return .success(data: true)
    }
}
