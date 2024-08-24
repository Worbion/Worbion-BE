//
//  UserEntity.swift
//
//
//  Created by Cemal on 27.05.2024.
//
import Vapor
import Fluent

// MARK: - UserEntity
final class UserEntity: Model, Authenticatable {
    static let schema = "users"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "surname")
    var surname: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "phone_number")
    var phoneNumber: String?
    
    @Field(key: "photo_url")
    var photoUrl: String?
    
    @Field(key: "bio")
    var bio: String?
    
    @Field(key: "is_corporate")
    var isCorporate: Bool
    
    @OptionalParent(key: "created_by")
    var createdBy: UserEntity?
    
    @Field(key: "instagram_identifier")
    var instagramId: String?
    
    @Field(key: "tiktok_identifier")
    var tiktokId: String?
    
    @Field(key: "x_identifier")
    var xId: String?
    
    @Field(key: "website_url")
    var websiteUrl: String?
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "user_role")
    var role: UserRole
    
    @Field(key: "is_email_verified")
    var isEmailVerified: Bool
    
    @Field(key: "is_phone_verified")
    var isPhoneVerified: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
        id: Int64? = nil,
        name: String,
        surname: String,
        email: String,
        username: String,
        phoneNumber: String? = nil,
        photoUrl: String? = nil,
        bio: String? = nil,
        isCorporate: Bool = false,
        createdUserId: Int64? = nil,
        websiteUrl: String? = nil,
        passwordHash: String,
        role: UserRole = .user,
        isEmailVerified: Bool = false,
        isPhoneVerified: Bool = false
    ) {
        self.id = id
        self.name = name
        self.surname = surname
        self.email = email
        self.username = username
        self.phoneNumber = phoneNumber
        self.photoUrl = photoUrl
        self.bio = bio
        self.isCorporate = isCorporate
        self.$createdBy.id = createdUserId
        self.websiteUrl = websiteUrl
        self.passwordHash = passwordHash
        self.role = role
        self.isEmailVerified = isEmailVerified
        self.isPhoneVerified = isPhoneVerified
    }
}

// MARK: - Computed Properties
extension UserEntity {
    var isVerified: Bool {
        return isCorporate
    }
}

