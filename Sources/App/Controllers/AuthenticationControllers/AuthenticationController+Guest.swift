//
//  AuthenticationController+Guest.swift
//
//
//  Created by Cemal on 31.08.2024.
//

import Vapor
import Fluent

// MARK: - AuthenticationController+Guest
extension AuthenticationController {
    func boot(guest routes: any RoutesBuilder) {
        routes.post("login", use: login)
    }
}

fileprivate extension AuthenticationController {
    @Sendable
    func login(request: Request) async throws -> BaseResponse<GuestLoginResponse> {
        let guestAccessToken = try request.jwt.sign(GuestPayload())
        let guestLoginResponse = GuestLoginResponse(accessToken: guestAccessToken)
        
        return .success(data: guestLoginResponse)
    }
}
