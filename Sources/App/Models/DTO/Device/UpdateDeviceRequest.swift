//
//  UpdateDeviceRequest.swift
//
//
//  Created by Cemal on 29.07.2024.
//

import Vapor

// MARK: - UpdateDeviceRequest
struct UpdateDeviceRequest: Content {
    let pushToken: String
}

// MARK: - Validatable
extension UpdateDeviceRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("pushToken", as: String.self, is: !.empty)
    }
}
