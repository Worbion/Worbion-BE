//
//  CRUUserAddressRequest.swift
//
//
//  Created by Cemal on 3.08.2024.
//

import Vapor

// MARK: - CRUUserAddressRequest
struct CRUUserAddressRequest: Content {
    let name: String
    let surname: String
    let phoneNumber: String
    let provienceId: Int64
    let districtId: Int64
    let neighbourhoodId: Int64
    let title: String
    let direction: String
}

// MARK: - Validatable
extension CRUUserAddressRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: .count(2...))
        validations.add("surname", as: String.self, is: .count(2...))
        validations.add("phoneNumber", as: String.self, is: .characterSet(.decimalDigits))
        validations.add("provienceId", as: Int64.self, is: .range(1...81))
        validations.add("districtId", as: Int64.self, is: .range(1...))
        validations.add("neighbourhoodId", as: Int64.self, is: .range(1...))
        validations.add("title", as: String.self, is: !.empty)
        validations.add("direction", as: String.self, is: !.empty)
    }
}

// MARK: - Equatable
extension CRUUserAddressRequest: Equatable {
    static func == (lhs: CRUUserAddressRequest, rhs: CRUUserAddressRequest) -> Bool {
        return lhs.name == rhs.name && lhs.surname == rhs.surname && lhs.phoneNumber == rhs.phoneNumber && lhs.provienceId == rhs.provienceId && lhs.districtId == rhs.districtId && lhs.neighbourhoodId == rhs.neighbourhoodId && lhs.title == rhs.title && lhs.direction == rhs.direction
    }
}

// MARK: - Update
extension UserAddressEntity {
    func updateFieldsIfNeeded(update request: CRUUserAddressRequest)-> Bool {
        let existModel = self.toRequest
        
        guard existModel != request else {
            return false
        }
        
        holderName = request.name
        holderSurname = request.surname
        holderPhoneNumber = request.phoneNumber
        provienceId = request.provienceId
        districtId = request.districtId
        neighbourhoodId = request.neighbourhoodId
        title = request.title
        direction = request.direction
        return true
    }
}

// MARK: - UserAddressEntity + CRUUserAddressRequest
extension UserAddressEntity {
    convenience init(
        create request: CRUUserAddressRequest,
        userId: UserEntity.IDValue
    ) {
        self.init(
            userId: userId,
            holderName: request.name,
            holderSurname: request.surname,
            holderPhoneNumber: request.phoneNumber,
            provienceId: request.provienceId,
            districtId: request.districtId,
            neighbourhoodId: request.neighbourhoodId,
            title: request.title,
            direction: request.direction
        )
    }
    
    var toRequest: CRUUserAddressRequest {
        return .init(
            name: holderName,
            surname: holderSurname,
            phoneNumber: holderPhoneNumber,
            provienceId: provienceId,
            districtId: districtId,
            neighbourhoodId: neighbourhoodId,
            title: title,
            direction: direction
        )
    }
}
