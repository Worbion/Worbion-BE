//
//  ConsentUpdateRequestDTO.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor

// MARK: - ConsentUpdateRequestDTO
struct ConsentUpdateRequestDTO: Content, Equatable {
    let consentName: String
    let consentCaption: String
}

// MARK: - Validatable
extension ConsentUpdateRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("consentName", as: String.self, is: !.empty)
        validations.add("consentCaption", as: String.self, is: !.empty)
    }
}

// MARK: - Fake Update Request
fileprivate extension ConsentEntity {
    var fakeUpdateRequest: ConsentUpdateRequestDTO {
        return ConsentUpdateRequestDTO(
            consentName: consentName,
            consentCaption: consentCaption
        )
    }
}

// MARK: - Compare and update
extension ConsentEntity {
    func compareAndUpdateFieldsIfCanDo(with updateRequest: ConsentUpdateRequestDTO) -> Bool {
        guard fakeUpdateRequest != updateRequest else { return false }
        consentName = updateRequest.consentName
        consentCaption = updateRequest.consentCaption
        return true
    }
}
