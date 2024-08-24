//
//  ConsentsByLocationEntity.swift
//
//
//  Created by Cemal on 24.08.2024.
//

import Vapor
import Fluent

// MARK: - ConsentsByLocationEntity
final class ConsentsByLocationEntity: Model, Content {
    static let schema = "consents_by_location"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Parent(key: "consent_id")
    var consent: ConsentEntity
    
    @Field(key: "consent_location_type")
    var consentLocation: ConsentsByLocationEntityEnum
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(
        consentId: ConsentEntity.IDValue,
        consentLocation: ConsentsByLocationEntityEnum
    ) {
        self.$consent.id = consentId
        self.consentLocation = consentLocation
    }
}
