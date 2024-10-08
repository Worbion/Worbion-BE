//
//  GuestPayload.swift
//  
//
//  Created by Cemal on 31.08.2024.
//

import Vapor
import JWT

struct GuestPayload: JWTPayload, Authenticatable {
    var deviceId: String
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
    
    init(deviceId: String) {
        self.deviceId = deviceId
        role = .guest
        exp = ExpirationClaim(value: Date().addingTimeInterval(.accessTokenLifeTime))
    }
}
