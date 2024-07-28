//
//  UserController.swift
//
//
//  Created by Cemal on 22.07.2024.
//

import Vapor
import Fluent
import Queues

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("user") { user in
            // Get User Credentials
            user.group(UserAuthenticator()) { authenticated in
                authenticated.get(":id", use: fetchUserInfo(request:))
            }
            
            // Admin Permission Required
            user.group(AdminAuthenticator()) { authenticated in
                authenticated.post(use: self.createUserFromPanel(request:))
            }
        }
    }
}

// MARK: - Panel User Control
private extension UserController {
    /// Fetch info of user
    /// - Parameter request: Request
    /// - Returns: UserProfileResponse **User information visible to anyone registered**
    @Sendable
    func fetchUserInfo(request: Request) async throws -> BaseResponse<UserProfileResponse> {
        guard
            let userIdParameter = request.parameters.get("id"),
            let userId = Int64(userIdParameter)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "UserId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }

        guard
            let userEntity = try await UserEntity.find(userId, on: request.db)
        else {
            let error = GeneralError.generic(
                userMessage: "User not found",
                systemMessage: "User not found",
                status: .notFound
            )
            throw error
        }
        
        let userResponse = UserProfileResponse(entity: userEntity)
        return .success(data: userResponse)
    }
    
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

