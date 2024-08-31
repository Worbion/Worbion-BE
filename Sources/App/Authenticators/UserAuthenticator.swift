//
//  UserAuthenticator.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor
import JWT

struct UserAuthenticator: JWTAuthenticator {
    typealias Payload = App.Payload
    
    func authenticate(jwt: Payload, for request: Request) -> EventLoopFuture<Void> {
        guard
            jwt.role.doCheckPermission(has: .user)
        else {
            let error = Abort(.unauthorized)
            return request.eventLoop.makeFailedFuture(error)
        }
        request.auth.login(jwt)
        return request.eventLoop.makeSucceededFuture(())
    }
}

