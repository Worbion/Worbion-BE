//
//  RepositoryProviders.swift
//
//
//  Created by Cemal on 2.09.2024.
//

import Vapor

// MARK: - Repository Provider
extension Application.Repositories {
    struct Provider {
        static var database: Self {
            .init {
                $0.repositories.use { UserDatabaseRepositoryImpl(database: $0.db) }
                $0.repositories.use { RefreshTokenRepositoryImpl(database: $0.db) }
                $0.repositories.use { EmailTokenRepositoryImpl(database: $0.db) }
                $0.repositories.use { PasswordTokenRepositoryImpl(database: $0.db) }
                $0.repositories.use { UserDeviceDatabaseRepositoryImpl(database: $0.db) }
                $0.repositories.use { ConsentRepositoryImpl(database: $0.db) }
            }
        }
        
        let run: (Application) -> ()
    }
    
    func use(_ provider: Provider) {
        provider.run(app)
    }
}
