//
//  ClientUserDTOModelS.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

// MARK: - ClientUserDTOModelS
struct ClientUserDTOModelS: Content {
    let id: Int64?
    let name: String
    let surname: String
    let username: String
    let email: String
    let photoUrl: String?
    let role: UserRole
    
    init(id: Int64? = nil, name: String, surname: String, username: String, email: String, photoUrl: String? = nil, role: UserRole) {
        self.id = id
        self.name = name
        self.surname = surname
        self.username = username
        self.email = email
        self.photoUrl = photoUrl
        self.role = role
    }
    
    init(from user: UserEntity) {
        self.init(id: user.id, name: user.name, surname: user.surname, username: user.username, email: user.email, photoUrl: user.photoUrl, role: user.role)
    }
}
