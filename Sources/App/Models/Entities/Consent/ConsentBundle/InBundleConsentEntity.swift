//
//  InBundleConsentEntity.swift
//  
//
//  Created by Cemal on 28.08.2024.
//

import Vapor
import Fluent

// MARK: - InBundleConsentEntity
final class InBundleConsentEntity: Model, Content {
    static let schema = "in_bundle_consents"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Parent(key: "consent_id")
    var consent: ConsentEntity
    
    @Parent(key: "consent_bundle_id")
    var bundle: ConsentBundleEntity
    
    @Field(key: "is_required")
    var isRequired: Bool
    
    @Field(key: "confirmation_text")
    var confirmationText: String
    
    @Field(key: "confirmation_clickable_part_text")
    var confirmationClickablePartText: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
        consentId: ConsentEntity.IDValue,
        bundleId: ConsentBundleEntity.IDValue,
        isRequired: Bool,
        confirmationText: String,
        confirmationClickablePartText: String
    ) {
        self.$consent.id = consentId
        self.$bundle.id = bundleId
        self.isRequired = isRequired
        self.confirmationText = confirmationText
        self.confirmationClickablePartText = confirmationClickablePartText
    }
}
