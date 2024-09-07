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
}
