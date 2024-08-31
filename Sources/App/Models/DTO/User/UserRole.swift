//
//  UserRole.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

enum UserRole: String, Content, CaseIterable {
    case guest = "guest"
    case user = "user"
    case croupier = "croupier"
    case moderator = "moderator"
    case admin = "admin"
    case superadmin = "superadmin"
}

extension UserRole {
    var roleLevel: Int {
        switch self {
        case .guest:
            return 0
        case .user:
            return 1
        case .croupier:
            return 2
        case .moderator:
            return 3
        case .admin:
            return 4
        case .superadmin:
            return 5
        }
    }
}

extension UserRole {
    func doCheckPermission(has role: UserRole) -> Bool {
        return roleLevel >= role.roleLevel
    }
}
