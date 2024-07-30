//
//  ConsentVersionResponse.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor

// MARK: - ConsentVersionResponse
struct ConsentVersionResponse: Content {
    let consentHtml: String
    let version: Double
}

// MARK: - ConsentVersionXLResponse
struct ConsentVersionXLResponse: Content {
    let id: Int64?
    let consentHtml: String
    let version: Double
    let createdAt: Date?
}

// MARK: - ConsentVersionEntity + ConsentVersionResponse
extension ConsentVersionEntity {
    var mapConsentVersionResponse: ConsentVersionResponse {
        return ConsentVersionResponse(consentHtml: htmlString, version: version)
    }
}

// MARK: - ConsentVersionEntity + ConsentVersionXLResponse
extension ConsentVersionEntity {
    var mapConsentVersionXLResponse: ConsentVersionXLResponse {
        return ConsentVersionXLResponse(id: id, consentHtml: htmlString, version: version, createdAt: createdAt)
    }
}
