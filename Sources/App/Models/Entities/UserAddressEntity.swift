//
//  UserAddressEntity.swift
//  
//
//  Created by Cemal on 3.08.2024.
//

import Vapor
import Fluent

final class UserAddressEntity: Model {
    static let schema = "user_addresses"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Parent(key: "user_id")
    var user: UserEntity
    
    @Field(key: "address_holder_name")
    var holderName: String
    
    @Field(key: "address_holder_surname")
    var holderSurname: String
    
    @Field(key: "address_holder_phone")
    var holderPhoneNumber: String
    
    @Field(key: "address_provience_id")
    var provienceId: Int64
    
    @Field(key: "address_district_id")
    var districtId: Int64
    
    @Field(key: "address_neighbourhood_id")
    var neighbourhoodId: Int64
    
    @Field(key: "address_title")
    var title: String
    
    @Field(key: "address_direction")
    var direction: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
        userId: UserEntity.IDValue,
        holderName: String,
        holderSurname: String,
        holderPhoneNumber: String,
        provienceId: Int64,
        districtId: Int64,
        neighbourhoodId: Int64,
        title: String,
        direction: String
    ) {
        $user.id = userId
        self.holderName = holderName
        self.holderSurname = holderSurname
        self.holderPhoneNumber = holderPhoneNumber
        self.provienceId = provienceId
        self.districtId = districtId
        self.neighbourhoodId = neighbourhoodId
        self.title = title
        self.direction = direction
    }
}
