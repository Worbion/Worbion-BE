//
//  AuthenticationController.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor
import Fluent

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("auth") { auth in
            auth.group("guest", configure: boot(guest:))
            
            auth.group("panel") { panelPath in
                panelPath.group(CroupierAuthenticator()) { panelAuthenticated in
                    panelAuthenticated.post("login", use: login)
                }
            }
            
            auth.post("register", use: register)
            auth.post("login", use: login)
            auth.put("logout", use: logout)
            
            auth.group("email-verification") { emailVerificationRoutes in
                emailVerificationRoutes.post("", use: sendEmailVerification)
                emailVerificationRoutes.get("", use: verifyEmail)
            }
            
            auth.group("reset-password") { resetPasswordRoutes in
                resetPasswordRoutes.post("", use: resetPassword)
                resetPasswordRoutes.get("verify", use: verifyResetPasswordToken)
            }
            auth.post("recover", use: recoverAccount)
            
            auth.post("accessToken", use: refreshAccessToken)
        }
    }
}

// MARK: - Register
private extension AuthenticationController {
    @Sendable
    func register(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        try RegisterRequest.validate(content: request)
        let registerRequest = try request.content.decodeRequestContent(content: RegisterRequest.self)
        
        guard registerRequest.password == registerRequest.confirmPassword else {
            throw AuthenticationError.passwordsDontMatch
        }
        
        let passwordHash = try await request.password.async.hash(registerRequest.password)
        let user = try UserEntity(from: registerRequest, hash: passwordHash)
        
        do {
            try await request.users.create(user)
        }catch {
            guard error.isDBConstraintFailureError,
                  let failureConstraintDescription = error.failedConstraintDescription else {
                throw error
            }
            
            if failureConstraintDescription.contains("email") {
                throw AuthenticationError.emailAlreadyExists
            }else if failureConstraintDescription.contains("username") {
                throw AuthenticationError.usernameAlreadyExist
            }else if failureConstraintDescription.contains("phone_number") {
                throw AuthenticationError.phoneAlreadyExist
            }
            throw error
        }
        
        try await request.emailVerifier.verify(for: user)
        return .success()
    }
}

// MARK: - Login
private extension AuthenticationController {
    @Sendable
    func login(request: Request) async throws -> BaseResponse<LoginResponse> {
        try LoginRequest.validate(content: request)
        let loginRequest = try request.content.decodeRequestContent(content: LoginRequest.self)
        
        guard let relatedUser = try await request.users.find(loginRequest.email) else {
            throw AuthenticationError.invalidEmailOrPassword
        }
        
        guard relatedUser.isEmailVerified else { throw AuthenticationError.emailIsNotVerified }
        
        let passwordVerificationResult = try await request.password.async.verify(loginRequest.password, created: relatedUser.passwordHash)
        
        guard passwordVerificationResult else { throw AuthenticationError.invalidEmailOrPassword }
    
        try await request.refreshTokens.delete(for: relatedUser.requireID())
        
        let token = request.random.generate(bits: 256)
        let hashedToken = SHA256.hash(token)
        let refreshToken = try RefreshTokenEntity(token: hashedToken, userID: relatedUser.requireID())
        
        try await request.refreshTokens.create(refreshToken)
        
        // Create relation between device and user
        if let deviceUid = request.getCustomHeaderField(by: .deviceId) {
            do {
                try await request.userDevices.set(\.$user.$id, to: try relatedUser.requireID(), for: deviceUid)
            }catch {
                request.logger.report(error: error)
            }
        }
        
        let loginResponse = LoginResponse(
            accessToken: try request.jwt.sign(Payload(with: relatedUser)),
            refreshToken: token
        )
        
        return .success(data: loginResponse)
    }
    
    @Sendable
    func logout(request: Request) async throws -> BaseResponse<Bool> {
        // Remove the relation between user and device
        if let deviceUid = request.getCustomHeaderField(by: .deviceId) {
            try await request.userDevices.removeUserDeviceRelation(deviceUid: deviceUid)
        }
        return .success(data: true)
    }
}

// MARK: - Refresh Access Token
private extension AuthenticationController {
    @Sendable
    func refreshAccessToken(request: Request) async throws -> BaseResponse<AccessTokenResponse> {
        let accessTokenRequest = try request.content.decodeRequestContent(
            content: AccessTokenRequest.self,
            specMessage: "Refresh token required"
        )
        
        let hashedRefreshToken = SHA256.hash(accessTokenRequest.refreshToken)
        
        
        guard let relatedRefreshToken = try await request.refreshTokens.find(token: hashedRefreshToken) else {
            throw AuthenticationError.refreshTokenOrUserNotFound
        }
        
        try await request.refreshTokens.delete(relatedRefreshToken)
        
        guard relatedRefreshToken.expiresAt > Date() else {
            throw AuthenticationError.refreshTokenHasExpired
        }
        
        let relatedUser = relatedRefreshToken.user
        
        let token = request.random.generate(bits: 256)
        let refreshToken = try RefreshTokenEntity(token: SHA256.hash(token), userID: relatedUser.requireID())
        let payload = try Payload(with: relatedUser)
        let accessToken = try request.jwt.sign(payload)
        
        try await request.refreshTokens.create(refreshToken)
        
        let response = AccessTokenResponse(
            refreshToken: token,
            accessToken: accessToken
        )
        
        return .success(data: response)
    }
}

// MARK: - Verify Email
private extension AuthenticationController {
    @Sendable
    func verifyEmail(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        let token = try request.query.get(
            decodableType: String.self,
            at: "token",
            specMessage: "Verification mail token required"
        )
        
        let hashedToken = SHA256.hash(token)
        
        guard let emailToken = try await request.emailTokens.find(token: hashedToken) else {
            throw AuthenticationError.emailTokenNotFound
        }
        
        try await request.emailTokens.delete(emailToken)
        
        guard emailToken.expiresAt > Date() else { throw AuthenticationError.emailTokenHasExpired }
        
        try await request.users.set(\.$isEmailVerified, to: true, for: emailToken.$user.id)
        
        return .success()
    }
}

// MARK: - Reset Password Request
private extension AuthenticationController {
    @Sendable
    func resetPassword(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        let resetPasswordRequest = try request.content.decodeRequestContent(content: ResetPasswordRequest.self)
        
        guard let relatedUserEntity = try await request.users.find(resetPasswordRequest.email) else {
            throw AuthenticationError.userNotFound
        }
        
        try await request.passwordResetter.reset(for: relatedUserEntity)
        return .success()
    }
}

// MARK: - Verify Reset Password Token
private extension AuthenticationController {
    @Sendable
    func verifyResetPasswordToken(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        let token = try request.query.get(
            decodableType: String.self,
            at: "token",
            specMessage: "Reset password token required."
        )
        
        let hashedToken = SHA256.hash(token)
        
        guard let passwordToken = try await request.passwordTokens.find(token: hashedToken) else {
            throw AuthenticationError.invalidPasswordToken
        }
        
        guard passwordToken.expiresAt > Date() else {
            try await request.passwordTokens.delete(passwordToken)
            throw AuthenticationError.passwordTokenHasExpired
        }
        
        return .success()
    }
}

// MARK: - Recover Account
private extension AuthenticationController {
    @Sendable
    func recoverAccount(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        try RecoverAccountRequest.validate(content: request)
        let recoverAccountRequest = try request.content.decodeRequestContent(content: RecoverAccountRequest.self)
        
        guard recoverAccountRequest.password == recoverAccountRequest.confirmPassword else {
            throw AuthenticationError.passwordsDontMatch
        }
        
        let hashedToken = SHA256.hash(recoverAccountRequest.token)
        
        guard let passwordTokenEntity = try await request.passwordTokens.find(token: hashedToken) else {
            throw AuthenticationError.invalidPasswordToken
        }
        
        guard passwordTokenEntity.expiresAt > Date() else {
            try await request.passwordTokens.delete(passwordTokenEntity)
            throw AuthenticationError.passwordTokenHasExpired
        }
        
        let newPasswordHash = try await request.password.async.hash(recoverAccountRequest.password)
        
        try await request.users.set(\.$passwordHash, to: newPasswordHash, for: passwordTokenEntity.$user.id)
        
        try await request.passwordTokens.delete(for: passwordTokenEntity.$user.id)

        return .success()
    }
}

// MARK: - Send Email Verification
private extension AuthenticationController {
    @Sendable
    func sendEmailVerification(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        let content = try request.content.decodeRequestContent(content: SendEmailVerificationRequest.self)
        
        guard let relatedUser = try await request.users.find(content.email) else {
            throw AuthenticationError.invalidEmail
        }
        
        guard !relatedUser.isEmailVerified else {
            throw AuthenticationError.emailAlreadyVerified
        }
        
        try await request.emailVerifier.verify(for: relatedUser)
        return .success()
    }
}
