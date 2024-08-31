//
//  AddConsentToBundleRequestDTO.swift
//
//
//  Created by Cemal on 30.08.2024.
//

import Vapor

// MARK: - AddConsentToBundleRequestDTO
struct AddConsentToBundleRequestDTO: Content {
    let consentId: ConsentEntity.IDValue
    let isRequired: Bool
    let confirmationText: String
    let confirmationClickablePartText: String
}

// MARK: - Validatable
extension AddConsentToBundleRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("consentId", as: ConsentEntity.IDValue.self, is: .range(1...))
    }
}

// MARK: - InBundleConsentEntity + AddConsentToBundleRequestDTO
extension InBundleConsentEntity {
    convenience init(request create: AddConsentToBundleRequestDTO, bundleId: ConsentBundleEntity.IDValue) {
        self.init(
            consentId: create.consentId,
            bundleId: bundleId,
            isRequired: create.isRequired,
            confirmationText: create.confirmationText,
            confirmationClickablePartText: create.confirmationClickablePartText
        )
    }
}
