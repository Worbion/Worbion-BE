//
//  ConsentCreateRequest.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor

// MARK: - ConsentCreateRequest
struct ConsentCreateRequest: Content {
    let consentName: String
    let consentCaption: String
    let consentType: ConsentType
}

// MARK: - Validatable
extension ConsentCreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("consentName", as: String.self, is: !.empty)
        validations.add("consentCaption", as: String.self, is: !.empty)
    }
}

// MARK: - ConsentEntity + Create Consent
extension ConsentEntity {
    convenience init(
        create request: ConsentCreateRequest
    ) {
        self.init(
            consentName: request.consentName,
            consentCaption: request.consentCaption,
            consentType: request.consentType
        )
    }
}
