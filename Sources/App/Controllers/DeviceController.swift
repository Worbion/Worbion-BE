//
//  DeviceController.swift
//
//
//  Created by Cemal on 29.07.2024.
//

import Vapor
import Fluent

// MARK: - DeviceController
struct DeviceController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("devices") { devices in
            devices.post(":deviceId",use: registerDevice(request:))
            devices.put(":deviceId", use: updateDevice(request:))
        }
    }
}

extension DeviceController {
    @Sendable
    func registerDevice(request: Request) async throws -> BaseResponse<Bool> {
        try RegisterDeviceRequest.validate(content: request)
    
        let registerDeviceRequest = try request.content.decodeRequestContent(content: RegisterDeviceRequest.self)
        
        guard
            let deviceId = request.parameters.get("deviceId", as: String.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "deviceId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
        
        let entity = DeviceEntity(create: registerDeviceRequest, device: deviceId)
        
        do {
            try await entity.save(on: request.db)
        }catch {
            if let dbError = error as? DatabaseError, dbError.isConstraintFailure {
                let message = "This device has already registered. You cant register again. You can update push token of this device"
                let error = GeneralError.generic(userMessage: nil, systemMessage: message, status: .conflict)
                throw error
            }
            throw error
        }
        
        return .success(data: true)
    }
    
    @Sendable
    func updateDevice(request: Request) async throws -> BaseResponse<Bool> {
        try UpdateDeviceRequest.validate(content: request)
        
        let updateDeviceRequest = try request.content.decodeRequestContent(content: UpdateDeviceRequest.self)
        
        guard
            let deviceId = request.parameters.get("deviceId", as: String.self)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "deviceId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }
                
        try await DeviceEntity.query(on: request.db)
            .filter(\.$deviceId == deviceId)
            .set(\.$pushToken, to: updateDeviceRequest.pushToken)
            .update()
        
        return .success(data: true)
    }
}
