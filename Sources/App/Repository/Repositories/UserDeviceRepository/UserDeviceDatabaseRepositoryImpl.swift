//
//  UserDeviceDatabaseRepositoryImpl.swift
//
//
//  Created by Cemal on 3.09.2024.
//

import Fluent
import Vapor

// MARK: - UserDeviceDatabaseRepositoryImpl
struct UserDeviceDatabaseRepositoryImpl: UserDeviceRepository.UserDeviceDatabaseRepository {
    let database: Database
    
    func removeUserDeviceRelation(deviceUid: String) async throws {
        try await DeviceEntity.query(on: database)
            .filter(\.$deviceId == deviceUid)
            .set(\.$user.$id, to: nil)
            .update()
    }
}

// MARK: - User Repository + Application
extension Application.Repositories {
    var userDevices: UserDeviceRepository {
        guard let storage = storage.makeUserDeviceRepository else {
            fatalError("UserRepository not configured")
        }
        
        return storage(app)
    }
    
    func use(_ make: @escaping (Application) -> (UserDeviceRepository)) {
        storage.makeUserDeviceRepository = make
    }
}



