//
//  ConsentBundleEntity.swift
//
//
//  Created by Cemal on 25.08.2024.
//

import Vapor
import Fluent

// MARK: - ConsentBundleEntity
/// Every row represents a package of multiple consents.
/// It keeps together the agreements that the user approve at any location. (For example: registering, joining the game, etc.)
final class ConsentBundleEntity: Model, Content {
    static let schema = "consent_bundles"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Field(key: "consent_bundle_type")
    /// Server-Side must know the types of some consent bundle types (like register.)
    /// But  doesn't have to know them all. Static cosents are kept in the ConsentBundleEntityEnum class.
    var type: String
    
    @Field(key: "consent_bundle_name")
    var name: String
    
    @Field(key: "consent_bundle_description")
    var bundleDescription: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    // The consent relations covered by bundle
    @Children(for: \.$bundle)
    var bundleConsents: [InBundleConsentEntity]
    
    init() {}
    
    init(
        type: String,
        name: String,
        bundleDescription: String
    ) {
        self.type = type
        self.name = name
        self.bundleDescription = bundleDescription
    }
}
