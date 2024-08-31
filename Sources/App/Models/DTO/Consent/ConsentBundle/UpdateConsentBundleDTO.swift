//
//  UpdateConsentBundleDTO.swift
//
//
//  Created by Cemal on 28.08.2024.
//

import Vapor

// MARK: - UpdateConsentBundleDTO
struct UpdateConsentBundleDTO: Content, Equatable {
    let bundleType: String
    let bundleName: String
    let bundleDescription: String
}

extension UpdateConsentBundleDTO: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("bundleType", as: String.self, is: !.empty)
        validations.add("bundleName", as: String.self, is: !.empty)
        validations.add("bundleName", as: String.self, is: .alphanumeric)
        validations.add("bundleDescription", as: String.self, is: !.empty)
    }
}

// MARK: - ConsentBundleEntity + UpdateConsentBundleDTO
fileprivate extension ConsentBundleEntity {
    var fakeUpdateRequest: UpdateConsentBundleDTO {
        return .init(bundleType: type, bundleName: name, bundleDescription: bundleDescription)
    }
}

// MARK: - Update
extension ConsentBundleEntity {
    final func checkAndUpdateFieldsIfNeeded(request update: UpdateConsentBundleDTO) -> Bool {
        guard fakeUpdateRequest != update else {
            return false
        }
        name = update.bundleName
        type = update.bundleType
        bundleDescription = update.bundleDescription
        return true
    }
}
