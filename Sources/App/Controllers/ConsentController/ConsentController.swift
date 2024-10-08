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
        let keyPath = "consents"
        
        routes.group("panel", "\(keyPath)") { panel in
            panel.group(AdminAuthenticator()) { adminAuthenticated in
                boot(panel: adminAuthenticated)
            }
        }
        
        routes.group("\(keyPath)") { consents in
            consents.group(GuestAuthenticator()) { guestAuthenticated in
                guestAuthenticated.get("latest-version", use: getLastestVersionOfConsent)
                guestAuthenticated.get(use: getConsentsFromBundle)
            }
        }
    }
}

// MARK: - Consent Version Operations
private extension ConsentController {
    @Sendable
    /// Fetch most current and published version of the requested consent type
    /// - Returns: ConsentVersionResponse type to
    func getLastestVersionOfConsent(request: Request) async throws -> BaseResponse<ConsentVersionResponseDTO> {
        let consentType = try request.query.get(
            decodableType: String.self,
            at: "type"
        )
        
        let latestVersionOfConsent = try await request.consents.getLatestVersionOfConsent(consentType, true)

        guard let latestVersionOfConsent else {
            let message = "consent.error.consent_version_not_found"
            throw GeneralError.generic(
                userMessage: message,
                systemMessage: message,
                status: .notFound
            )
        }
        
        let response = ConsentVersionResponseDTO(
            consentName: latestVersionOfConsent.consent.consentName,
            consentHtml: latestVersionOfConsent.htmlString,
            version: latestVersionOfConsent.version
        )
        
        return .success(data: response)
    }
    
    @Sendable
    /// Returns consents by consent bundle type.
    /// - Returns: ConsentBundleResponse array
    func getConsentsFromBundle(request: Request) async throws -> BaseResponse<InConsentBundleConfirmationResponseDTO> {
        let bundleType = try request.query.get(
            decodableType: String.self,
            at: "bundleType",
            specMessage: "Bundle type is missing or incorrect."
        )
        
        let inBundleConsents = try await request.consents.getInBundleConsents(bundleType)
        
        guard !inBundleConsents.isEmpty else {
            return .success(data: nil)
        }
        
        let responseItems = inBundleConsents.compactMap { $0.mapToInBundleConsentConfirmationResponse(request: request) }
        let response = InConsentBundleConfirmationResponseDTO(consents: responseItems)
        return .success(data: response)
    }
}
