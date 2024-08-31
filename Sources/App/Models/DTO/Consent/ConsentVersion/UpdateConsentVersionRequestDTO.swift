//
//  UpdateConsentVersionRequestDTO.swift
//
//
//  Created by Cemal on 25.08.2024.
//

import Vapor

// MARK: - UpdateConsentVersionRequestDTO
struct UpdateConsentVersionRequestDTO: Content, Equatable {
    let isPublished: Bool
}

// MARK: - Fake Update Request
fileprivate extension ConsentVersionEntity {
    var fakeUpdateRequest: UpdateConsentVersionRequestDTO {
        return .init(isPublished: isPublished)
    }
}

// MARK: - Compare And Update
extension ConsentVersionEntity {
    func compareAndUpdateIfNeeded(request update: UpdateConsentVersionRequestDTO) -> Bool {
        guard fakeUpdateRequest != update else {
            return false
        }
        isPublished = update.isPublished
        return true
    }
}
