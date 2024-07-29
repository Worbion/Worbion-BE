//
//  ConsentVersionResponse.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor

// MARK: - ConsentVersionResponse
struct ConsentVersionResponse: Content {
    let consentUrl: String
    let version: Double
}

// MARK: - ConsentVersionXLResponse
struct ConsentVersionXLResponse: Content {
    let id: Int64?
    let consentUrl: String
    let version: Double
    let createdAt: Date?
}

extension ConsentVersionEntity {
    var mapConsentVersionResponse: ConsentVersionResponse {
        return .init(consentUrl: url, version: version)
    }
    
    var mapConsentVersionXLResponse: ConsentVersionXLResponse {
        return .init(id: id, consentUrl: url, version: version, createdAt: createdAt)
    }
}
