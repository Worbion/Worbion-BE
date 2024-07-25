//
//  CroupierAuthenticator.swift
//
//
//  Created by Cemal on 20.07.2024.
//

import Vapor
import JWT

struct CroupierAuthenticator: JWTAuthenticator {
    typealias Payload = App.Payload
    
    func authenticate(jwt: Payload, for request: Request) -> EventLoopFuture<Void> {
        guard
            jwt.role.doCheckPermission(has: .croupier)
        else {
            let error = Abort(.unauthorized)
            return request.eventLoop.makeFailedFuture(error)
        }
        request.auth.login(jwt)
        return request.eventLoop.makeSucceededFuture(())
    }
}


