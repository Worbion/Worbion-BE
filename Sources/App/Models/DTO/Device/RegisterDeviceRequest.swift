//
//  RegisterDeviceRequest.swift
//
//
//  Created by Cemal on 29.07.2024.
//

import Vapor

// MARK: - RegisterDeviceRequest
struct RegisterDeviceRequest: Content {
    let pushToken: String
    let deviceOSType: DeviceOSType
}

// MARK: - Validatable
extension RegisterDeviceRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("pushToken", as: String.self, is: !.empty)
    }
}

// MARK: - DeviceEntity + RegisterDeviceRequest Constructor
extension DeviceEntity {
    convenience init(
        create request: RegisterDeviceRequest,
        device id: String
    ) {
        self.init(
            deviceId: id,
            pushToken: request.pushToken,
            deviceOSType: request.deviceOSType
        )
    }
}
