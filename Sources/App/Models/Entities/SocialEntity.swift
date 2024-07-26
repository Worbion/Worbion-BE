//
//  SocialEntity.swift
//
//
//  Created by Cemal on 25.07.2024.
//

import Vapor
import Fluent

// MARK: - SocialEntity
final class SocialEntity: Model {
    static let schema = "socials"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Field(key: "social_name")
    var socialName: String
    
    @Field(key: "social_icon_url")
    var socialIconUrl: String
    
    /// The name of the key that defines the account. (For example, if it is YouTube, it is the channel, if it is Instagram, it is the username)
    /// It is used to specify the relevant identifier when asking the user for social media account information. Like:
    /// Please, enter your youtube **channel name** information.
    /// Please, enter your instagram **username** information.
    @Field(key: "social_identifier_key_name")
    var socialIDKName: String
    
    /// The socialReplaceKey that indicates which word will replace the social identifier given by the user in the **socialProfileUrlTemplate**.
    @Field(key: "social_identifier_replace_key")
    var socialReplaceKey: String
    
    /// Social media link template
    @Field(key: "social_profile_url_template")
    var socialProfileUrlTemplate: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
}
