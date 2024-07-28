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
            auth.post("register", use: register)
            auth.post("login", use: login)
            
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
            try await user.create(on: request.db)
        }catch {
            if let dbError = error as? DatabaseError, dbError.isConstraintFailure {
                throw AuthenticationError.emailAlreadyExists
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
        
        guard let relatedUser = try await UserEntity.query(on: request.db)
            .filter(\.$email == loginRequest.email)
            .first()
        else {
            throw AuthenticationError.invalidEmailOrPassword
        }
        
        guard relatedUser.isEmailVerified else { throw AuthenticationError.emailIsNotVerified }
        
        let passwordVerificationResult = try await request.password.async.verify(loginRequest.password, created: relatedUser.passwordHash)
        
        guard passwordVerificationResult else { throw AuthenticationError.invalidEmailOrPassword }
    
        try await RefreshTokenEntity.query(on: request.db)
            .filter(\.$user.$id == relatedUser.requireID())
            .delete()
        
        let token = request.random.generate(bits: 256)
        let hashedToken = SHA256.hash(token)
        let refreshToken = try RefreshTokenEntity(token: hashedToken, userID: relatedUser.requireID())
        
        try await refreshToken.create(on: request.db)
        
        let loginResponse = LoginResponse(
            accessToken: try request.jwt.sign(Payload(with: relatedUser)),
            refreshToken: token
        )
        
        return .success(data: loginResponse)
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
        
        guard let relatedRefreshToken = try await RefreshTokenEntity.query(on: request.db)
            .with(\.$user)
            .filter(\.$token == hashedRefreshToken)
            .first()
        else {
            throw AuthenticationError.refreshTokenOrUserNotFound
        }
        
        try await relatedRefreshToken.delete(on: request.db)
        
        guard relatedRefreshToken.expiresAt > Date() else {
            throw AuthenticationError.refreshTokenHasExpired
        }
        
        let relatedUser = relatedRefreshToken.user
        
        let token = request.random.generate(bits: 256)
        let refreshToken = try RefreshTokenEntity(token: SHA256.hash(token), userID: relatedUser.requireID())
        let payload = try Payload(with: relatedUser)
        let accessToken = try request.jwt.sign(payload)
        
        try await refreshToken.create(on: request.db)
        
        let response = AccessTokenResponse(refreshToken: token, accessToken: accessToken)
        
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
        
        guard let emailToken = try await EmailTokenEntity.query(on: request.db)
            .filter(\.$token == hashedToken)
            .first()
        else {
            throw AuthenticationError.emailTokenNotFound
        }
        
        try await emailToken.delete(on: request.db)
        
        guard emailToken.expiresAt > Date() else { throw AuthenticationError.emailTokenHasExpired }
        
        try await UserEntity.query(on: request.db)
            .filter(\.$id == emailToken.$user.id)
            .set(\.$isEmailVerified, to: true)
            .update()
        
        return .success()
    }
}

// MARK: - Reset Password Request
private extension AuthenticationController {
    @Sendable
    func resetPassword(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        let resetPasswordRequest = try request.content.decodeRequestContent(content: ResetPasswordRequest.self)
        
        guard let relatedUserEntity = try await UserEntity.query(on: request.db)
            .filter(\.$email == resetPasswordRequest.email)
            .first()
        else {
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
        
        guard let passwordToken = try await PasswordTokenEntity.query(on: request.db)
            .filter(\.$token == hashedToken)
            .first()
        else {
            throw AuthenticationError.invalidPasswordToken
        }
        
        guard passwordToken.expiresAt > Date() else {
            try await passwordToken.delete(on: request.db)
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
        
        guard let passwordTokenEntity = try await PasswordTokenEntity.query(on: request.db)
            .filter(\.$token == hashedToken)
            .first() else {
            throw AuthenticationError.invalidPasswordToken
        }
        
        guard passwordTokenEntity.expiresAt > Date() else {
            try await passwordTokenEntity.delete(on: request.db)
            throw AuthenticationError.passwordTokenHasExpired
        }
        
        let newPasswordHash = try await request.password.async.hash(recoverAccountRequest.password)
        
        try await UserEntity.query(on: request.db)
            .filter(\.$id == passwordTokenEntity.$user.id)
            .set(\.$passwordHash, to: newPasswordHash)
            .update()
        
        try await PasswordTokenEntity.query(on: request.db)
            .filter(\.$user.$id == passwordTokenEntity.$user.id)
            .delete()

        return .success()
    }
}

// MARK: - Send Email Verification
private extension AuthenticationController {
    @Sendable
    func sendEmailVerification(request: Request) async throws -> BaseResponse<BaseEmptyResponse> {
        let content = try request.content.decodeRequestContent(content: SendEmailVerificationRequest.self)
        
        guard let relatedUser = try await UserEntity.query(on: request.db)
            .filter(\.$email == content.email)
            .first() else {
            throw AuthenticationError.invalidEmail
        }
        
        guard !relatedUser.isEmailVerified else {
            throw AuthenticationError.emailAlreadyVerified
        }
        
        try await request.emailVerifier.verify(for: relatedUser)
        return .success()
    }
}
