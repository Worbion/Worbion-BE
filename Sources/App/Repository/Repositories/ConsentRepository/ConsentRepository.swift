//
//  ConsentRepository.swift
//
//
//  Created by Cemal on 7.09.2024.
//

import Vapor
import Fluent

// MARK: - ConsentRepository
protocol ConsentRepository: Repository {
    typealias ConsentDatabaseRepository = ConsentRepository & DatabaseRepository
    
    func find(_ consentId: ConsentEntity.IDValue) async throws -> ConsentEntity?
    func all() async throws -> [ConsentEntity]
    func create(_ consent: ConsentEntity) async throws
    func update(_ consent: ConsentEntity) async throws
    
    func findVersion(_ id: ConsentVersionEntity.IDValue) async throws -> ConsentVersionEntity?
    func createVersion(_ version: ConsentVersionEntity, for consentId: ConsentEntity.IDValue) async throws
    func getVersions(_ version: Double?, for consentId: ConsentEntity.IDValue) async throws -> [ConsentVersionEntity]
    func updateVersion(_ version: ConsentVersionEntity) async throws
    func getLatestVersionOfConsent(_ consentType: String, _ isPublished: Bool?) async throws -> ConsentVersionEntity?
    
    func findConsentBundle(_ id: ConsentBundleEntity.IDValue) async throws -> ConsentBundleEntity?
    func getAllConsentBundles() async throws -> [ConsentBundleEntity]
    func createConsentBundle(_ consentBundle: ConsentBundleEntity) async throws
    func updateConsentBundle(_ consentBundle: ConsentBundleEntity) async throws
    func deleteConsentBundle(_ consentBundleID: ConsentBundleEntity.IDValue) async throws
    
    func getInBundleConsents(_ bundleType: String) async throws -> [InBundleConsentEntity]
    func createInBundleConsent(_ inBundleConsent: InBundleConsentEntity) async throws
    func deleteInBundleConsent(_ consentId: ConsentEntity.IDValue, _ inBundleConsentId: InBundleConsentEntity.IDValue) async throws
}

