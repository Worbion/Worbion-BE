//
//  AddressController.swift
//
//
//  Created by Cemal on 2.08.2024.
//

import Vapor
import Fluent

// MARK: - TODO: When address API ready, refactor this controller

// MARK: - AddressController
struct AddressController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("address") { address in
            address.group(UserAuthenticator()) { userAuth in
                userAuth.get("proviences", use: getProviences)
                userAuth.get("districts", use: getDistricts)
                userAuth.get("neighbourhoods", use: getNeighborhoods)
            }
        }
    }
}

// MARK: - Address Methods
extension AddressController {
    @Sendable
    func getProviences(request: Request) async throws -> BaseResponse<[AddressResponse]> {
        var response: [AddressResponse] = []
        
        for index in 1...81 {
            let mockTempAddressResponse = AddressResponse(id: index, name: "İl \(index)")
            response.append(mockTempAddressResponse)
        }
    
        return .success(data: response)
    }
    
    @Sendable
    func getDistricts(request: Request) async throws -> BaseResponse<[AddressResponse]> {
        let provienceId = try request.query.get(
            decodableType: Int.self,
            at: "provienceId",
            specMessage: "provienceId required"
        )
        
        var response: [AddressResponse] = []
        
        for index in 100...130 {
            let mockTempAddressResponse = AddressResponse(id: index, name: "İlçe \(index)")
            response.append(mockTempAddressResponse)
        }
    
        return .success(data: response)
    }
    
    @Sendable
    func getNeighborhoods(request: Request) async throws -> BaseResponse<[AddressResponse]> {
        let districtId = try request.query.get(
            decodableType: Int.self,
            at: "districtId",
            specMessage: "districtId required"
        )
        
        var response: [AddressResponse] = []
        
        for index in 200...215 {
            let mockTempAddressResponse = AddressResponse(id: index, name: "Mahalle \(index)")
            response.append(mockTempAddressResponse)
        }
    
        return .success(data: response)
    }
}
