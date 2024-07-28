//
//  Payload.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor
import JWT

struct Payload: JWTPayload, Authenticatable {
    var userID: Int64
    var role: UserRole
    var exp: ExpirationClaim
    
    func verify(using signer: JWTSigner) throws {
        do {
            try self.exp.verifyNotExpired()
        } catch {
            let error = AuthenticationError.authTokenExpired
            throw error
        }
        
    }
    
    init(with user: UserEntity) throws {
        self.userID = try user.requireID()
        self.role = user.role
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(.accessTokenLifeTime))
    }
}

extension UserEntity {
    convenience init(from payload: Payload) {
        self.init(id: payload.userID, name: "", surname: "", email: "", username: "", passwordHash: "")
    }
}

