//
//  ConsentVersionResponseDTO.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor

// MARK: - ConsentVersionResponseDTO
// Visible for client
struct ConsentVersionResponseDTO: Content {
    let consentName: String
    let consentHtml: String
    let version: Double
}

// MARK: - ConsentVersionXLResponseDTO
// Visible from panel
struct ConsentVersionXLResponseDTO: Content {
    let id: Int64?
    let consentHtml: String
    let version: Double
    let createdAt: Date?
    let isPublished: Bool
}

// MARK: - ConsentVersionEntity + ConsentVersionResponseDTO
extension ConsentVersionEntity {
    var mapConsentVersionResponse: ConsentVersionResponseDTO {
        return ConsentVersionResponseDTO(
            consentName: consent.consentName,
            consentHtml: htmlString,
            version: version
        )
    }
}

// MARK: - ConsentVersionEntity + ConsentVersionXLResponseDTO
extension ConsentVersionEntity {
    var mapConsentVersionXLResponse: ConsentVersionXLResponseDTO {
        return ConsentVersionXLResponseDTO(
            id: id,
            consentHtml: htmlString,
            version: version,
            createdAt: createdAt,
            isPublished: isPublished
        )
    }
}
