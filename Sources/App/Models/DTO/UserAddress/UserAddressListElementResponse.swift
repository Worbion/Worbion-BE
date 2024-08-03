//
//  UserAddressListElementResponse.swift
//
//
//  Created by Cemal on 3.08.2024.
//

import Vapor

// MARK: - UserAddressListElementResponse
struct UserAddressListElementResponse: Content {
    let id: Int64?
    let title: String
    let fullName: String
    let phone: String
    let direction: String
}

// MARK: - UserAddressEntity + UserAddressListElementResponse
extension UserAddressEntity {
    var mapToAddressListElementResponse: UserAddressListElementResponse {
        let fullName = "\(holderName) \(holderSurname)"
        return .init(id: id, title: title, fullName: fullName, phone: holderPhoneNumber, direction: direction)
    }
}
