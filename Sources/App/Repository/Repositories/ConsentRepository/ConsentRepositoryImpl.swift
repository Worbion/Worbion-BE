//
//  ConsentRepositoryImpl.swift
//
//
//  Created by Cemal on 7.09.2024.
//

import Fluent
import Vapor

// MARK: - ConsentRepositoryImpl
struct ConsentRepositoryImpl: ConsentRepository.ConsentDatabaseRepository {

    let database: Database
    
    func find(_ consentId: ConsentEntity.IDValue) async throws -> ConsentEntity? {
        return try await ConsentEntity.find(consentId, on: database)
    }
    
    func all() async throws -> [ConsentEntity] {
        return try await ConsentEntity.query(on: database).all()
    }
    
    func create(_ consent: ConsentEntity) async throws {
        try await consent.save(on: database)
    }
    
    func update(_ consent: ConsentEntity) async throws {
        try await consent.update(on: database)
    }
}

// MARK: - Version
extension ConsentRepositoryImpl {
    func findVersion(_ id: ConsentVersionEntity.IDValue) async throws -> ConsentVersionEntity? {
        return try await ConsentVersionEntity.find(id, on: database)
    }
    
    func getLatestVersionOfConsent(_ consentType: String, _ isPublished: Bool?) async throws -> ConsentVersionEntity? {
        let consentVersionQuery = ConsentVersionEntity.query(on: database)
            .join(parent: \ConsentVersionEntity.$consent)
            .filter(ConsentEntity.self, \.$consentType == consentType)
        
        if let isPublished {
            consentVersionQuery.filter(\ConsentVersionEntity.$isPublished == isPublished)
        }
        
        return try await consentVersionQuery.sort(\ConsentVersionEntity.$version, .descending)
            .with(\.$consent)
            .first()
    }
    
    func createVersion(_ version: ConsentVersionEntity, for consentId: ConsentEntity.IDValue) async throws {
        guard let consent = try await find(consentId) else {
            let message = "Consent not found"
            throw GeneralError.generic(userMessage: message, systemMessage: message, status: .notFound)
        }
        
        try await consent.$versions.create(version, on: database)
    }
    
    func getVersions(_ version: Double?, for consentId: ConsentEntity.IDValue) async throws -> [ConsentVersionEntity] {
        let versionQuery = ConsentVersionEntity.query(on: database)
            .filter(\.$consent.$id == consentId)
        
        if let version {
            versionQuery.filter(\.$version == version)
        }
        
        return try await versionQuery.all()
    }
    
    func updateVersion(_ version: ConsentVersionEntity) async throws {
        try await version.update(on: database)
    }
}

// MARK: - Consent Bundle
extension ConsentRepositoryImpl {
    func findConsentBundle(_ id: ConsentBundleEntity.IDValue) async throws -> ConsentBundleEntity? {
        return try await ConsentBundleEntity.find(id, on: database)
    }
    
    func getAllConsentBundles() async throws -> [ConsentBundleEntity] {
        return try await ConsentBundleEntity.query(on: database).all()
    }
    
    func createConsentBundle(_ consentBundle: ConsentBundleEntity) async throws {
        try await consentBundle.save(on: database)
    }
    
    func updateConsentBundle(_ consentBundle: ConsentBundleEntity) async throws {
        try await consentBundle.update(on: database)
    }
    
    func deleteConsentBundle(_ consentBundleID: ConsentBundleEntity.IDValue) async throws {
        try await ConsentBundleEntity.query(on: database)
            .filter(\.$id == consentBundleID)
            .delete()
    }
}

// MARK: - In Bundle Consents
extension ConsentRepositoryImpl {
    func getInBundleConsents(_ bundleType: String) async throws -> [InBundleConsentEntity] {
        return try await InBundleConsentEntity.query(on: database)
            .join(parent: \InBundleConsentEntity.$bundle)
            .filter(ConsentBundleEntity.self, \.$type == bundleType)
            .with(\.$consent)
            .all()
    }
    
    func createInBundleConsent(_ inBundleConsent: InBundleConsentEntity) async throws {
        try await inBundleConsent.save(on: database)
    }
    
    func deleteInBundleConsent(_ consentId: ConsentEntity.IDValue, _ inBundleConsentId: InBundleConsentEntity.IDValue) async throws {
        try await InBundleConsentEntity.query(on: database)
            .filter(\.$consent.$id == consentId)
            .filter(\.$bundle.$id == inBundleConsentId)
            .delete()
    }
}


// MARK: - User Repository + Application
extension Application.Repositories {
    var consents: ConsentRepository {
        guard let storage = storage.makeConsentRepository else {
            fatalError("ConsentRepository not configured")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (ConsentRepository)) {
        storage.makeConsentRepository = make
    }
}
