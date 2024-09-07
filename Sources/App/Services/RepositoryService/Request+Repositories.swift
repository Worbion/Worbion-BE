//
//  Request+Repositories.swift
//  
//
//  Created by Cemal on 2.09.2024.
//

import Vapor

// MARK: - Request+Repositories
extension Request {
    var users: UserRepository { application.repositories.users.for(self) }
    var refreshTokens: RefreshTokenRepository { application.repositories.refreshTokens.for(self) }
    var emailTokens: EmailTokenRepository { application.repositories.emailTokens.for(self) }
    var passwordTokens: PasswordTokenRepository { application.repositories.passwordTokens.for(self) }
    var userDevices: UserDeviceRepository { application.repositories.userDevices.for(self) }
    var consents: ConsentRepository { application.repositories.consents.for(self) }
    var banks: BankRepository { application.repositories.banks.for(self) }
}
