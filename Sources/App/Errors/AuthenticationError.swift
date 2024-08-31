//
//  AuthenticationError.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

enum AuthenticationError: BaseError {
    case passwordsDontMatch
    case emailAlreadyExists
    case invalidEmailOrPassword
    case invalidEmail
    case refreshTokenOrUserNotFound
    case refreshTokenHasExpired
    case userNotFound
    case emailTokenHasExpired
    case emailTokenNotFound
    case emailIsNotVerified
    case invalidPasswordToken
    case passwordTokenHasExpired
    case emailAlreadyVerified
    case authTokenExpired
}

// MARK: - Error HTTP Status
extension AuthenticationError {
    var status: HTTPResponseStatus {
        switch self {
        case .passwordsDontMatch:
            return .badRequest
        case .emailAlreadyExists:
            return .badRequest
        case .emailTokenHasExpired:
            return .badRequest
        case .invalidEmailOrPassword:
            return .unauthorized
        case .invalidEmail:
            return .notFound
        case .refreshTokenOrUserNotFound:
            return .notFound
        case .userNotFound:
            return .notFound
        case .emailTokenNotFound:
            return .notFound
        case .refreshTokenHasExpired:
            return .unauthorized
        case .emailIsNotVerified:
            return .unauthorized
        case .invalidPasswordToken:
            return .notFound
        case .passwordTokenHasExpired:
            return .unauthorized
        case .emailAlreadyVerified:
            return .badRequest
        case .authTokenExpired:
            return .unauthorized
        }
    }
}

// MARK: - Error User Message
extension AuthenticationError {
    var identifier: String {
        switch self {
        case .passwordsDontMatch:
            return "auth.passwords_dont_match"
        case .emailAlreadyExists:
            return "auth.email_already_exists"
        case .invalidEmailOrPassword:
            return "auth.invalid_email_or_password"
        case .invalidEmail:
            return "auth.invalid_email"
        case .refreshTokenOrUserNotFound:
            return "auth.refresh_token_or_user_not_found"
        case .refreshTokenHasExpired:
            return "auth.refresh_token_has_expired"
        case .userNotFound:
            return "auth.user_not_found"
        case .emailTokenNotFound:
            return "auth.email_token_not_found"
        case .emailTokenHasExpired:
            return "auth.email_token_has_expired"
        case .emailIsNotVerified:
            return "auth.email_is_not_verified"
        case .invalidPasswordToken:
            return "auth.invalid_password_token"
        case .passwordTokenHasExpired:
            return "auth.password_token_has_expired"
        case .emailAlreadyVerified:
            return "auth.email_already_verified"
        case .authTokenExpired:
            return "auth.authentication_token_has_expired"
        }
    }
}

// MARK: - Error System Message
extension AuthenticationError {
    var systemMessage: String {
        switch self {
        case .passwordsDontMatch:
            return "Passwords did not match"
        case .emailAlreadyExists:
            return "A user with that email already exists"
        case .invalidEmailOrPassword:
            return "Email or password was incorrect"
        case .invalidEmail:
            return "Email is invalid"
        case .refreshTokenOrUserNotFound:
            return "User or refresh token was not found"
        case .refreshTokenHasExpired:
            return "Refresh token has expired"
        case .userNotFound:
            return "User was not found"
        case .emailTokenNotFound:
            return "Email token not found"
        case .emailTokenHasExpired:
            return "Email token has expired"
        case .emailIsNotVerified:
            return "Email is not verified"
        case .invalidPasswordToken:
            return "Invalid reset password token"
        case .passwordTokenHasExpired:
            return "Reset password token has expired"
        case .emailAlreadyVerified:
            return "Email already verified."
        case .authTokenExpired:
            return "Authentication token has expired"
        }
    }
}

// MARK: - Error User Message
extension AuthenticationError {
    var userMessage: String? {
        switch self {
        case .passwordsDontMatch:
            return "passwords_dont_match"
        case .emailAlreadyExists:
            return "email_already_exists"
        case .invalidEmailOrPassword:
            return "invalid_email_or_password"
        case .invalidEmail:
            return "invalid_email"
        case .userNotFound:
            return "user_not_found"
        case .emailTokenHasExpired:
            return "email_token_has_expired"
        case .emailIsNotVerified:
            return "email_is_not_verified"
        case .passwordTokenHasExpired:
            return "password_token_has_expired"
        default:
            return nil
        }
    }
}
