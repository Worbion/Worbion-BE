//
//  EmailTokenEntity.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor
import Fluent

final class EmailTokenEntity: Model {
    static let schema = "user_email_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: UserEntity
    
    @Field(key: "token")
    var token: String
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    init() {}
    
    init(
        id: UUID? = nil,
        userID: UUID,
        token: String,
        expiresAt: Date = Date().addingTimeInterval(.accessTokenLifeTime)
    ) {
        self.id = id
        self.$user.id = userID
        self.token = token
        self.expiresAt = expiresAt
    }
}

