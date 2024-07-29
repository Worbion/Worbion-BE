//
//  CreateConsentVersionRequest.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor

// MARK: - CreateConsentVersionRequest
struct CreateConsentVersionRequest: Content {
    let version: String
    let consentFile: Data
}

// MARK: - Validatable
extension CreateConsentVersionRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("version", as: String.self, is: !.empty)
        validations.add("version", as: String.self, is: .init(validate: { versionStr in
            let validator = StringDoubleValidator(valueStr: versionStr)
            return validator
        }))
        validations.add("consentFile", as: Data.self, is: !.empty)
    }
}

extension ConsentVersionEntity {
    convenience init?(
        create request: CreateConsentVersionRequest,
        consentId: ConsentEntity.IDValue,
        url: String
    ) {
        guard let doubleVersion = Double(request.version) else { return nil }
        self.init(consentId: consentId, version: doubleVersion, url: url)
    }
}
