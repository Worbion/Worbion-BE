//
//  CreateUserFromPanelRequest.swift
//
//
//  Created by Cemal on 22.07.2024.
//

import Vapor

// MARK: - CreateUserFromPanelRequest
struct CreateUserFromPanelRequest: Content {
    let name: String
    let surname: String
    let email: String
    let username: String
    let isCorporate: Bool
    let isEmailVerified: Bool
    let shouldSendMembershipInfo: Bool
    var photoUrl: String?
    var instagramIdentifier: String?
    var xIdentifier: String?
    var threadsIdentifier: String?
    var tiktokIdentifier: String?
    var websiteUrl: String?
}

// MARK: - Validatable
extension CreateUserFromPanelRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}

extension UserEntity {
    convenience init(
        from register: CreateUserFromPanelRequest,
        hash: String,
        generatedUserBy: Int64
    ) throws {
        self.init(
            name: register.name,
            surname: register.surname,
            email: register.email,
            username: register.username,
            photoUrl: register.photoUrl,
            isCorporate: register.isCorporate,
            createdUserId: generatedUserBy,
            websiteUrl: register.websiteUrl,
            passwordHash: hash,
            isEmailVerified: register.isEmailVerified
        )
    }
}

