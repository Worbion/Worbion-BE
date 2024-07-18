//
//  UserDTO.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

struct UserDTO: Content {
    let id: UUID?
    let fullName: String
    let email: String
    let role: UserRole
    
    init(id: UUID? = nil, fullName: String, email: String, role: UserRole) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.role = role
    }
    
    init(from user: UserEntity) {
        self.init(id: user.id, fullName: user.fullName, email: user.email, role: user.role)
    }
}

