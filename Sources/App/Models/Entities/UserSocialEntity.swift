//
//  UserSocialEntity.swift
//  
//
//  Created by Cemal on 25.07.2024.
//

import Vapor
import Fluent

// MARK: - UserSocialEntity
final class UserSocialEntity: Model {
    static let schema = "user_socials"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Parent(key: "user_id")
    var user: UserEntity
    
    @Parent(key: "social_id")
    var social: SocialEntity
    
    @Field(key: "social_identifier")
    var identifier: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
}
