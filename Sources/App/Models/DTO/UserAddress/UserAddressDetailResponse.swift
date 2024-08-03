//
//  UserAddressDetailResponse.swift
//
//
//  Created by Cemal on 3.08.2024.
//

import Vapor

// MARK: - UserAddressDetailResponse
struct UserAddressDetailResponse: Content {
    let id: Int64?
    let name: String
    let surname: String
    let phoneNumber: String
    let provienceId: Int64
    let districtId: Int64
    let neighbourhoodId: Int64
    let addressTitle: String
    let addressDirection: String
}

// MARK: - UserAddressEntity + UserAddressDetailResponse
extension UserAddressEntity {
    var mapToAddressDetailResponse: UserAddressDetailResponse {
        return .init(
            id: id, 
            name: holderName,
            surname: holderSurname,
            phoneNumber: holderPhoneNumber,
            provienceId: provienceId,
            districtId: districtId,
            neighbourhoodId: neighbourhoodId,
            addressTitle: title,
            addressDirection: direction
        )
    }
}
