//
//  CreateConsentEntity.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor
import Fluent

// MARK: - ConsentEntity
final class ConsentEntity: Model, Content {
    static let schema = "consents"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Field(key: "consent_name")
    var consentName: String
    
    @Field(key: "consent_caption")
    var consentCaption: String
    
    @Field(key: "consent_type")
    var consentType: ConsentType
    
    @Field(key: "is_published")
    var isPublished: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Children(for: \.$consent)
    var versions: [ConsentVersionEntity]
    
    init() {}
    
    init(
        consentName: String, 
        consentCaption: String,
        consentType: ConsentType,
        isPublished: Bool
    ) {
        self.consentName = consentName
        self.consentCaption = consentCaption
        self.consentType = consentType
        self.isPublished = false
    }
}
