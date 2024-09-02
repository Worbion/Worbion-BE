//
//  UserController+Panel.swift
//
//
//  Created by Cemal on 31.08.2024.
//

import Vapor
import Fluent

// MARK: - UserController+Panel
extension UserController {
    func boot(panel routes: any RoutesBuilder) {
        routes.group(AdminAuthenticator()) { panelAuthenticated in
            panelAuthenticated.post(use: self.createUserFromPanel(request:))
        }
    }
}

fileprivate extension UserController {
    @Sendable
    func createUserFromPanel(request: Request) async throws -> BaseResponse<CreateUserFromPanelResponse> {
        let payload = try request.auth.require(Payload.self)
        
        try CreateUserFromPanelRequest.validate(content: request)
        let registerRequest = try request.content.decodeRequestContent(content: CreateUserFromPanelRequest.self)
        
        let randomPassword = RandomPasswordGenerator(passwordCount: 8).generate()
        
        let passwordHash = try await request.password.async.hash(randomPassword)
        let user = try UserEntity(from: registerRequest, hash: passwordHash, generatedUserBy: payload.userID)
        
        do {
            try await user.create(on: request.db)
        }catch {
            if let dbError = error as? DatabaseError, dbError.isConstraintFailure {
                throw AuthenticationError.emailAlreadyExists
            }
            throw error
        }
        
        if registerRequest.shouldSendMembershipInfo {
            
            let passwordRequestUrl = request.application.config.frontendURL + "/passwordResetRequest?=\(registerRequest.email)"
            let membershipCredentialsInfoMail = MembershipInfoMail(
                name: registerRequest.name,
                surname: registerRequest.surname,
                username: registerRequest.username,
                emailAddress: registerRequest.email,
                password: randomPassword,
                passworsResetRequestUrl: passwordRequestUrl
            )
            
            try await request.queue.dispatch(EmailJob.self, .init(membershipCredentialsInfoMail, to: registerRequest.email))
        }
        return .success(data: .init(userId: user.id))
    }
}
