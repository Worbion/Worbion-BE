//
//  RefreshTokenEntity.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor
import Fluent

final class RefreshTokenEntity: Model {
    static let schema = "user_refresh_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token")
    var token: String
    
    @Parent(key: "user_id")
    var user: UserEntity
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Field(key: "issued_at")
    var issuedAt: Date
    
    init() {}
    
    init(
        id: UUID? = nil,
        token: String,
        userID: UUID,
        expiresAt: Date = Date().addingTimeInterval(.refreshTokenLifeTime),
        issuedAt: Date = Date()
    ) {
        self.id = id
        self.token = token
        self.$user.id = userID
        self.expiresAt = expiresAt
        self.issuedAt = issuedAt
    }
}

