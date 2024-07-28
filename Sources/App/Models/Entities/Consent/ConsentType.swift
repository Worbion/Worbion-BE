//
//  ConsentType.swift
//
//
//  Created by Cemal on 28.07.2024.
//

import Vapor

// MARK: - ConsentType
enum ConsentType: String, Content, CaseIterable {
    case kvkkClarificationText = "kvkk_clarification_text"
    case privacyPolicy = "privacy_policy"
    case termsOfUse = "terms_of_use"
}
