//
//  CreateConsentVersionRequestDTO.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor

// MARK: - CreateConsentVersionRequestDTO
struct CreateConsentVersionRequestDTO: Content {
    let version: Double
    let consentHTML: String
    let isPublished: Bool
}

// MARK: - Validatable
extension CreateConsentVersionRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("version", as: Double.self, is: .range(1...))
        validations.add("consentHTML", as: String.self, is: !.empty)
    }
}

// MARK: - ConsentVersionEntity + CreateConsentVersionRequestDTO
extension ConsentVersionEntity {
    convenience init(
        create request: CreateConsentVersionRequestDTO,
        consentId: ConsentEntity.IDValue
    ) {
        self.init(
            consentId: consentId,
            version: request.version,
            htmlString: request.consentHTML,
            isPublished: request.isPublished
        )
    }
}
