//
//  UserDeviceRepository.swift
//
//
//  Created by Cemal on 3.09.2024.
//

import Vapor
import Fluent

// MARK: - UserDeviceRepository
protocol UserDeviceRepository: Repository {
    typealias UserDeviceDatabaseRepository = UserDeviceRepository & DatabaseRepository
    
    func removeUserDeviceRelation(deviceUid: String) async throws
    func create(userDevice: DeviceEntity) async throws
    func set<Field>(_ field: KeyPath<DeviceEntity, Field>, to value: Field.Value, for deviceUid: String) async throws where Field: QueryableProperty, Field.Model == DeviceEntity
}
