//
//  AuthenticationController+Guest.swift
//
//
//  Created by Cemal on 31.08.2024.
//

import Vapor

// MARK: - AuthenticationController+Guest
extension AuthenticationController {
    func boot(guest routes: any RoutesBuilder) {
        routes.post("login", use: login)
    }
}

fileprivate extension AuthenticationController {
    @Sendable
    func login(request: Request) async throws -> BaseResponse<GuestLoginResponse> {
        guard let deviceId = request.getCustomHeaderField(by: .deviceId) else {
            let message = "Auth fields required"
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: message,
                status: .badRequest
            )
        }
        
        let guestPayload = GuestPayload(deviceId: deviceId)
        let guestAccessToken = try request.jwt.sign(guestPayload)
        let guestLoginResponse = GuestLoginResponse(accessToken: guestAccessToken)
        
        return .success(data: guestLoginResponse)
    }
}
