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
    
    func create(userDevice: DeviceEntity) async throws {
        try await userDevice.save(on: database)
    }
    
    func set<Field>(_ field: KeyPath<DeviceEntity, Field>, to value: Field.Value, for deviceUid: String) async throws where Field : FluentKit.QueryableProperty, Field.Model == DeviceEntity {
        try await DeviceEntity.query(on: database)
            .filter(\.$deviceId == deviceUid)
            .set(field, to: value)
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



