//
//  UserRole.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

enum UserRole: String, Content, CaseIterable {
    case user = "user"
    case croupier = "croupier"
    case moderator = "moderator"
    case admin = "admin"
    case superadmin = "superadmin"
}

extension UserRole {
    var roleLevel: Int {
        switch self {
        case .user:
            return 0
        case .croupier:
            return 1
        case .moderator:
            return 2
        case .admin:
            return 3
        case .superadmin:
            return 4
        }
    }
}
