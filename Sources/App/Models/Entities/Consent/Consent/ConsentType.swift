//
//  ConsentType.swift
//
//
//  Created by Cemal on 29.07.2024.
//

import Vapor

// MARK: - ConsentType
enum ConsentType: String, Content, CaseIterable {
    case privacyPolicy = "privacy_policy"
    case useOfTerms = "use_of_terms"
    case kvvkClarificationText = "kvkk_clarification_text"
    
    var isUserVisibleAgreementType: Bool {
        return true
    }
}
