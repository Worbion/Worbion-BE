//
//  DeviceEntity.swift
//
//
//  Created by Cemal on 29.07.2024.
//

import Vapor
import Fluent

// MARK: - DeviceEntity
final class DeviceEntity: Model {
    static let schema = "devices"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @OptionalParent(key: "user_id")
    var user: UserEntity?
    
    @Field(key: "device_unique_id")
    var deviceId: String
    
    @Field(key: "push_token")
    var pushToken: String
    
    @Field(key: "device_os_Type")
    var deviceOS: DeviceOSType
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
        userId: UserEntity.IDValue? = nil,
        deviceId: String,
        pushToken: String,
        deviceOSType: DeviceOSType
    ) {
        $user.id = userId
        self.deviceId = deviceId
        self.pushToken = pushToken
        deviceOS = deviceOSType
    }
}
