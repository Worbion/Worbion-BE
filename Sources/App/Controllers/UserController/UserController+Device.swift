//
//  UserController+Device.swift
//
//
//  Created by Cemal on 31.08.2024.
//

import Vapor
import Fluent

// MARK: - UserController+Device
extension UserController {
    func boot(device routes: any RoutesBuilder) {
        routes.group(GuestAuthenticator()) { authenticated in
            authenticated.post(":deviceId",use: registerDevice(request:))
            authenticated.put(":deviceId", use: updateDevice(request:))
        }
    }
}

fileprivate extension UserController {
    @Sendable
    func registerDevice(request: Request) async throws -> BaseResponse<Bool> {
        try RegisterDeviceRequest.validate(content: request)
    
        let registerDeviceRequest = try request.content.decodeRequestContent(content: RegisterDeviceRequest.self)
        
        guard let deviceId = request.parameters.get("deviceId", as: String.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "deviceId is missing or incorrect parameter.",
                status: .badRequest
            )
        }
        
        let entity = DeviceEntity(create: registerDeviceRequest, device: deviceId)
        
        do {
            try await entity.save(on: request.db)
        }catch {
            if error.isDBConstraintFailureError {
                let message = "This device has already registered. You cant register again."
                throw GeneralError.generic(
                    userMessage: nil,
                    systemMessage: message,
                    status: .conflict
                )
            }
            throw error
        }
        return .success(data: true)
    }
    
    @Sendable
    func updateDevice(request: Request) async throws -> BaseResponse<Bool> {
        try UpdateDeviceRequest.validate(content: request)
        
        let updateDeviceRequest = try request.content.decodeRequestContent(content: UpdateDeviceRequest.self)
        
        guard let deviceId = request.parameters.get("deviceId", as: String.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "deviceId is missing or incorrect parameter.",
                status: .badRequest
            )
        }
                
        try await DeviceEntity.query(on: request.db)
            .filter(\.$deviceId == deviceId)
            .set(\.$pushToken, to: updateDeviceRequest.pushToken)
            .update()
        
        return .success(data: true)
    }
}
