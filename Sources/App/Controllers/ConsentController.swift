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
            }
        }
    }
}

private extension ConsentController {
    /// Fetch info of user
    /// - Parameter request: Request
    /// - Returns: UserProfileResponse **User information visible to anyone registered**
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
}
