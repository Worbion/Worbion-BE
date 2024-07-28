//
//  UserSocialResponse.swift
//
//
//  Created by Cemal on 27.07.2024.
//

import Vapor

// MARK: - UserSocialResponse
struct UserSocialResponse: Content {
    let socialType: SocialType
    let targetUrl: String?
}
