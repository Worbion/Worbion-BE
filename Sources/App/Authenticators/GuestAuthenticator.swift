//
//  GuestAuthenticator.swift
//
//
//  Created by Cemal on 31.08.2024.
//

import Vapor
import JWT

// MARK: - GuestAuthenticator
struct GuestAuthenticator: JWTAuthenticator {
    typealias Payload = App.Payload
    
    func authenticate(jwt: Payload, for request: Request) -> EventLoopFuture<Void> {
        request.auth.login(jwt)
        return request.eventLoop.makeSucceededFuture(())
    }
}
