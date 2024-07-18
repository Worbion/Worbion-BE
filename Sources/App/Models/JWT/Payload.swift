//
//  Payload.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor
import JWT

struct Payload: JWTPayload, Authenticatable {
    var userID: UUID
    var fullName: String
    var email: String
    var role: UserRole
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
    
    init(with user: UserEntity) throws {
        self.userID = try user.requireID()
        self.fullName = user.fullName
        self.email = user.email
        self.role = user.role
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(.accessTokenLifeTime))
    }
}

extension UserEntity {
    convenience init(from payload: Payload) {
        self.init(id: payload.userID, fullName: payload.fullName, email: payload.email, passwordHash: "", role: payload.role)
    }
}

