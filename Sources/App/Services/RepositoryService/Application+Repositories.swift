//
//  Application+Repositories.swift
//
//
//  Created by Cemal on 2.09.2024.
//

import Vapor
import Fluent

// MARK: - Application+Repositories
extension Application {
    struct Repositories {
        let app: Application
    }
    
    var repositories: Repositories {
        .init(app: self)
    }
}

// MARK: - Repository+Storage
extension Application.Repositories {
    final class Storage {
        var makeUserRepository: ((Application) -> UserRepository)?
        var makeRefreshTokenRepository: ((Application) -> RefreshTokenRepository)?
        var makeEmailTokenRepository: ((Application) -> EmailTokenRepository)?
        var makePasswordTokenRepository: ((Application) -> PasswordTokenRepository)?
        var makeUserDeviceRepository: ((Application) -> UserDeviceRepository)?
        var makeConsentRepository: ((Application) -> ConsentRepository)?
        init() { }
    }
    
    struct Key: StorageKey {
        typealias Value = Storage
    }
    
    var storage: Storage {
        if app.storage[Key.self] == nil {
            app.storage[Key.self] = .init()
        }
        
        return app.storage[Key.self]!
    }
}


