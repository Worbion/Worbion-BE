//
//  BankController.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor
import Fluent

// MARK: - BankController
struct BankController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("banks") { banks in
            banks.group("", configure: boot(panel:))
            
            banks.group(UserAuthenticator()) { userAuth in
                userAuth.get(use: getAllBanks)
            }
        }
    }
}

// MARK: - Bank Methods
extension BankController {
    @Sendable
    func getAllBanks(request: Request) async throws -> BaseResponse<[BankResponse]> {
        let bankEntities = try await request.banks.all()
        let response = bankEntities.compactMap { $0.mapBankResponse }
        return .success(data: response)
    }
}
