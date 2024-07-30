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
    let consentHTML: String
}

// MARK: - Validatable
extension CreateConsentVersionRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("version", as: String.self, is: !.empty)
        validations.add("version", as: String.self, is: .init(validate: { versionStr in
            let validator = StringDoubleValidator(valueStr: versionStr)
            return validator
        }))
        validations.add("consentHTML", as: String.self, is: !.empty)
    }
}

// MARK: - ConsentVersionEntity + CreateConsentVersionRequest
extension ConsentVersionEntity {
    convenience init(
        create request: CreateConsentVersionRequest,
        consentId: ConsentEntity.IDValue
    ) {
        let doubleVersion = Double(request.version) ?? 1.0
        self.init(consentId: consentId, version: doubleVersion, htmlString: request.consentHTML)
    }
}
