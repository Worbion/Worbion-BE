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
                authenticated.get(":id", use: fetchUserInfo(request:))
            }
            
            user.group("panel", configure: boot(panel:))
            user.group("devices", configure: boot(device:))
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

        guard let userEntity = try await request.users.find(userId) else {
            let message = "users.error.user_info.user_not_found"
            let error = GeneralError.generic(
                userMessage: message,
                systemMessage: "User not found",
                status: .notFound
            )
            throw error
        }
        
        let userResponse = UserProfileResponse(entity: userEntity)
        return .success(data: userResponse)
    }
}
