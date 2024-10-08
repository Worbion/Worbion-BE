//
//  ConsentVersionEntity.swift
//  
//
//  Created by Cemal on 28.07.2024.
//

import Vapor
import Fluent

// MARK: - ConsentVersionEntity
final class ConsentVersionEntity: Model, Content {
    static let schema = "consent_versions"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Parent(key: "consent_id")
    var consent: ConsentEntity
    
    @Field(key: "consent_version")
    var version: Double
    
    @Field(key: "consent_html")
    var htmlString: String
    
    @Field(key: "is_published")
    var isPublished: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(
        consentId: ConsentEntity.IDValue,
        version: Double,
        htmlString: String,
        isPublished: Bool
    ) {
        self.$consent.id = consentId
        self.version = version
        self.htmlString = htmlString
        self.isPublished = isPublished
    }
}
