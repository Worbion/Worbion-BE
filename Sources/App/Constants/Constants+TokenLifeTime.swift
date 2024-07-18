//
//  Constants+TokenLifeTime.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Foundation

// MARK: - Token LifeTime Values
extension Constants.TokenLifeTime {
    /// How long should access tokens live for. Default: 15 minutes (in seconds)
    static let ACCESS_TOKEN_LIFETIME: Double = 60 * 15
    /// How long should refresh tokens live for: Default: 7 days (in seconds)
    static let REFRESH_TOKEN_LIFETIME: Double = 60 * 60 * 24 * 7
    /// How long should the email tokens live for: Default 24 hours (in seconds)
    static let EMAIL_TOKEN_LIFETIME: Double = 60 * 60 * 24
    /// Lifetime of reset password tokens: Default 1 hour (seconds)
    static let RESET_PASSWORD_TOKEN_LIFETIME: Double = 60 * 60
}

// MARK: - Fast Access To Token Lifetime Values
extension TimeInterval {
    static var accessTokenLifeTime: Double {
        return Constants.TokenLifeTime.ACCESS_TOKEN_LIFETIME
    }
    
    static var refreshTokenLifeTime: Double {
        return Constants.TokenLifeTime.REFRESH_TOKEN_LIFETIME
    }
    
    static var emailTokenLifeTime: Double {
        return Constants.TokenLifeTime.EMAIL_TOKEN_LIFETIME
    }
    
    static var resetPasswordTokenLifeTime: Double {
        return Constants.TokenLifeTime.RESET_PASSWORD_TOKEN_LIFETIME
    }
}

