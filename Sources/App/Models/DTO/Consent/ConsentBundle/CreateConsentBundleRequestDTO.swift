//
//  CreateConsentBundleRequestDTO.swift
//
//
//  Created by Cemal on 28.08.2024.
//

import Vapor

// MARK: - CreateConsentBundleRequestDTO
struct CreateConsentBundleRequestDTO: Content {
    let bundleType: String
    let bundleName: String
    let bundleDescription: String
}

extension CreateConsentBundleRequestDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("bundleType", as: String.self, is: !.empty)
        validations.add("bundleName", as: String.self, is: !.empty)
        validations.add("bundleName", as: String.self, is: .alphanumeric)
        validations.add("bundleDescription", as: String.self, is: !.empty)
    }
}

// MARK: - CreateConsentBundleRequestDTO + ConsentBundleEntity
extension ConsentBundleEntity {
    convenience init(request create: CreateConsentBundleRequestDTO) {
        self.init(type: create.bundleType, name: create.bundleName, bundleDescription: create.bundleDescription)
    }
}
