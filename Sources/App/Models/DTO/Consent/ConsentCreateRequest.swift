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
    let consentVersion: Double
    let consentFile: Data
    var consentType: ConsentType
}

// MARK: - Validatable
extension ConsentCreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("consentName", as: String.self, is: !.empty)
        validations.add("consentName", as: String.self, is: .characterSet(.letters))
        validations.add("consentCaption", as: String.self, is: !.empty)
        validations.add("consentCaption", as: String.self, is: .characterSet(.letters))
        validations.add("consentVersion", as: Double.self, is: .range(1.0...))
        validations.add("consentFile", as: Data.self, is: !.empty)
    }
}

// MARK: - ConsentEntity + Create Consent
extension ConsentEntity {
    convenience init(
        create request: ConsentCreateRequest,
        consent url: String
    ) {
        self.init(
            consentName: request.consentName,
            consentCaption: request.consentCaption,
            consentVersion: request.consentVersion,
            consentUrl: url,
            consentType: request.consentType
        )
    }
}
