//
//  UserAddressController.swift
//
//
//  Created by Cemal on 3.08.2024.
//

import Vapor
import Fluent

// MARK: - UserAddressController
struct UserAddressController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("user-addresses") { userAddresses in
            userAddresses.group(UserAuthenticator()) { userAuth in
                userAuth.post(use: createUserAddress)
                userAuth.get(use: getUserAddresses)
                userAuth.get(":addressId",use: getAddressDetail)
                userAuth.put(":addressId", use: updateUserAddress(request:))
                userAuth.delete(":addressId", use: deleteAddress(request:))
            }
        }
    }
}

// MARK: - Bank Methods
extension UserAddressController {
    @Sendable
    func createUserAddress(request: Request) async throws -> BaseResponse<Bool> {
        let payload = try request.auth.require(Payload.self)
        
        try CRUUserAddressRequest.validate(content: request)
        
        let createUserAddressRequest = try request.content.decodeRequestContent(content: CRUUserAddressRequest.self)
        
        let entity = UserAddressEntity(create: createUserAddressRequest, userId: payload.userID)
        
        try await entity.save(on: request.db)
        return .success(data: true)
    }
    
    @Sendable
    func getUserAddresses(request: Request) async throws -> BaseResponse<[UserAddressListElementResponse]> {
        let payload = try request.auth.require(Payload.self)
        
        let result = try await UserAddressEntity.query(on: request.db)
            .filter(\.$user.$id == payload.userID)
            .all()
        
        let response = result.compactMap { $0.mapToAddressListElementResponse }
        
        return .success(data: response)
    }
    
    @Sendable
    func updateUserAddress(request: Request) async throws -> BaseResponse<Bool> {
        let payload = try request.auth.require(Payload.self)
        
        guard let addressId = request.parameters.get("addressId", as: Int64.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "addressId is missing or incorrect parameter.",
                status: .badRequest
            )
        }
        
        try CRUUserAddressRequest.validate(content: request)
        
        let updateUserAddressRequest = try request.content.decodeRequestContent(content: CRUUserAddressRequest.self)
        
        let addressEntity = try await UserAddressEntity.query(on: request.db)
            .filter(\.$user.$id == payload.userID)
            .filter(\.$id == addressId)
            .first()
        
        guard let addressEntity else {
            let message = "Address not found"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .notFound)
        }
        
        // Check is update needed
        guard addressEntity.updateFieldsIfNeeded(update: updateUserAddressRequest) else {
            let message = "Fields are same with exist address fields"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .badRequest)
        }
        
        try await addressEntity.update(on: request.db)
        
        return .success(data: true)
    }
    
    @Sendable
    func getAddressDetail(request: Request) async throws -> BaseResponse<UserAddressDetailResponse> {
        let payload = try request.auth.require(Payload.self)
        
        guard let addressId = request.parameters.get("addressId", as: Int64.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "addressId is missing or incorrect parameter.",
                status: .badRequest
            )
        }
        
        let addressEntity = try await UserAddressEntity.query(on: request.db)
            .filter(\.$user.$id == payload.userID)
            .filter(\.$id == addressId)
            .first()
        
        guard let addressEntity else {
            let message = "Address not found"
            throw GeneralError.generic(userMessage: nil, systemMessage: message, status: .notFound)
        }
        
        let response = addressEntity.mapToAddressDetailResponse
        return .success(data: response)
    }
    
    @Sendable
    func deleteAddress(request: Request) async throws -> BaseResponse<Bool> {
        let payload = try request.auth.require(Payload.self)
        
        guard let addressId = request.parameters.get("addressId", as: Int64.self) else {
            throw GeneralError.generic(
                userMessage: nil,
                systemMessage: "addressId is missing or incorrect parameter.",
                status: .badRequest
            )
        }
        
        try await UserAddressEntity.query(on: request.db)
            .filter(\.$user.$id == payload.userID)
            .filter(\.$id == addressId)
            .delete()
        
        return .success(data: true)
    }
}
