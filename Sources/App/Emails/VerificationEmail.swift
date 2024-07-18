//
//  VerificationEmail.swift
//
//
//  Created by Cemal on 27.05.2024.
//

struct VerificationEmail {
    let verifyUrl: String
    
    init(verifyUrl: String) {
        self.verifyUrl = verifyUrl
    }
}

// MARK: - VerificationEmail
extension VerificationEmail: Email {
    var subject: String {
        "Please verify your email"
    }
    
    var templateData: [String : String] {
        ["verify_url": verifyUrl]
    }
    
    var templateName: String {
        return "email_verification"
    }
}

