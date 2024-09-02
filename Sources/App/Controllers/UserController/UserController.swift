//
//  UserController.swift
//
//
//  Created by Cemal on 22.07.2024.
//

import Vapor
import Fluent
import Queues

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("user") { user in
            user.group(UserAuthenticator()) { authenticated in
                authenticated.get("check-username-available", use: checkUsernameAvailable(request:))
                authenticated.get(":id", use: fetchUserInfo(request:))
            }
            
            user.group("panel", configure: boot(panel:))
            user.group("devices", configure: <#T##(any RoutesBuilder) throws -> ()#>)
        }
    }
}

// MARK: - Panel User Control
private extension UserController {
    /// Fetch info of user
    /// - Parameter request: Request
    /// - Returns: UserProfileResponse **User information visible to anyone registered**
    @Sendable
    func fetchUserInfo(request: Request) async throws -> BaseResponse<UserProfileResponse> {
        guard
            let userIdParameter = request.parameters.get("id"),
            let userId = Int64(userIdParameter)
        else {
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: "UserId is missing or incorrect parameter.",
                status: .badRequest
            )
            throw error
        }

        guard
            let userEntity = try await UserEntity.find(userId, on: request.db)
        else {
            let error = GeneralError.generic(
                userMessage: "User not found",
                systemMessage: "User not found",
                status: .notFound
            )
            throw error
        }
        
        let userResponse = UserProfileResponse(entity: userEntity)
        return .success(data: userResponse)
    }
    
    @Sendable
    func checkUsernameAvailable(request: Request) async throws -> BaseResponse<Bool> {
        
        let username = try request.query.get(
            decodableType: String.self,
            at: "username",
            specMessage: "Username required"
        )
        
        let relatedUser = try await UserEntity.query(on: request.db)
            .filter(\.$username == username)
            .first()
        
        return .success(data: relatedUser == nil)
    }
}

