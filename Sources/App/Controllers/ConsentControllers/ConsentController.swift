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
            consents.group(AdminAuthenticator()) { adminAuthenticated in
                boot(panel: adminAuthenticated)
            }
            consents.group(UserAuthenticator()) { consents in
                consents.get("latest-version", use: getLastestVersionOfConsent(request:))
                consents.get("types", use: getAllUserVisibleConsentTypes(request:))
            }
        }
    }
}

// MARK: - Consent Operations
fileprivate extension ConsentController {    
    @Sendable
    func getAllUserVisibleConsentTypes(request: Request) async throws -> BaseResponse<[ConsentType]> {
        let consents = ConsentType.allCases.filter { $0.isUserVisibleAgreementType }
        return .success(data: consents)
    }
}

// MARK: - Consent Version Operations
private extension ConsentController {    
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
}
