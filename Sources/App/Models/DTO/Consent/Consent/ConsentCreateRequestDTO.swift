//
//  ConsentCreateRequestDTO.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor

// MARK: - ConsentCreateRequestDTO
struct ConsentCreateRequestDTO: Content {
    let consentName: String
    let consentCaption: String
    let consentType: String
}

// MARK: - Validatable
extension ConsentCreateRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("consentName", as: String.self, is: !.empty)
        validations.add("consentCaption", as: String.self, is: !.empty)
        validations.add("consentType", as: String.self, is: !.empty)
        validations.add("consentType", as: String.self, is: .count(5...))
    }
}

// MARK: - ConsentEntity + Create Consent
extension ConsentEntity {
    convenience init(
        create request: ConsentCreateRequestDTO
    ) {
        self.init(
            consentName: request.consentName,
            consentCaption: request.consentCaption,
            consentType: request.consentType
        )
    }
}
