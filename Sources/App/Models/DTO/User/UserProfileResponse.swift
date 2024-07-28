//
//  UserProfileResponse.swift
//
//
//  Created by Cemal on 25.07.2024.
//

import Vapor

// MARK: - UserProfileResponse
struct UserProfileResponse: Content {
    let firstCharOfName: String?
    let profilePhotoUrl: String?
    let username: String
    let socials: [UserSocialResponse]
    let registeredDate: Date?
    
    init(
        entity user: UserEntity
    ) {
        firstCharOfName = user.name.first?.uppercased()
        profilePhotoUrl = user.photoUrl
        username = user.username
        socials = [
            SocialUtility(
                socialType: .instagram,
                identifier: user.instagramId
            ),
            SocialUtility(
                socialType: .tiktok,
                identifier: user.tiktokId
            ),
            SocialUtility(
                socialType: .x,
                identifier: user.xId
            )
        ].compactMap {
            return $0.mapResponse
        }
        registeredDate = user.createdAt
    }
}
