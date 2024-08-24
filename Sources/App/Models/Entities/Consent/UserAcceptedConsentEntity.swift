//
//  UserAcceptedConsentEntity.swift
//
//
//  Created by Cemal on 24.08.2024.
//

import Vapor
import Fluent

// MARK: - UserAcceptedConsentEntity
final class UserAcceptedConsentEntity: Model, Content {
    static let schema = "user_accepted_consents"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Parent(key: "user_id")
    var user: UserEntity
    
    @Parent(key: "consent_version")
    var contentVersion: ConsentVersionEntity
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(
        userId: UserEntity.IDValue,
        contentVersionId: ConsentVersionEntity.IDValue
    ) {
        self.$user.id = userId
        self.contentVersion.id = contentVersionId
    }
}
