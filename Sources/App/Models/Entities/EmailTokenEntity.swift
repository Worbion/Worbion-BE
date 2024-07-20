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
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Parent(key: "user_id")
    var user: UserEntity
    
    @Field(key: "token")
    var token: String
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    init() {}
    
    init(
        userID: Int64,
        token: String,
        expiresAt: Date = Date().addingTimeInterval(.accessTokenLifeTime)
    ) {
        self.id = id
        self.$user.id = userID
        self.token = token
        self.expiresAt = expiresAt
    }
}
