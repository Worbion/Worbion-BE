//
//  ConsentUpdateRequest.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor

// MARK: - ConsentUpdateRequest
struct ConsentUpdateRequest: Content {
    let consentName: String
    let consentCaption: String
}

// MARK: - Validatable
extension ConsentUpdateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("consentName", as: String.self, is: !.empty)
        validations.add("consentCaption", as: String.self, is: !.empty)
    }
}

extension ConsentEntity {
    func compareAndUpdateFieldsIfCanDo(with updateRequest: ConsentUpdateRequest) -> Bool {
        guard
            consentName != updateRequest.consentName ||
            consentCaption != updateRequest.consentCaption
        else {
            return false
        }
        consentName = updateRequest.consentName
        consentCaption = updateRequest.consentCaption
        return true
    }
}
