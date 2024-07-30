//
//  BankEntity.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor
import Fluent

// MARK: - BankEntity
final class BankEntity: Model, Content {
    static let schema = "banks"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Field(key: "bank_name")
    var bankName: String
    
    @Field(key: "bank_icon_url")
    var iconUrl: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
        bankName: String,
        iconUrl: String
    ) {
        self.bankName = bankName
        self.iconUrl = iconUrl
    }
}

