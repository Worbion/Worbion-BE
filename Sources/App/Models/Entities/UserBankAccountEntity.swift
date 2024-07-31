//
//  UserBankAccountEntity.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor
import Fluent

final class UserBankAccountEntity: Model {
    static let schema = "user_bank_accounts"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Parent(key: "bank_id")
    var bank: BankEntity
    
    @Parent(key: "user_id")
    var user: UserEntity
    
    @Field(key: "holder_full_name")
    var holderFullName: String
    
    @Field(key: "bank_account")
    var bankAccount: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
        bankID: BankEntity.IDValue,
        userID: UserEntity.IDValue,
        holderFullName: String,
        bankAccount: String
    ) {
        self.$bank.id = bankID
        self.$user.id = userID
        self.holderFullName = holderFullName
        self.bankAccount = bankAccount
    }
}

