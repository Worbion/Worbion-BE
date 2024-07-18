//
//  ResetPasswordEmail.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Foundation

// MARK: - ResetPasswordEmail
struct ResetPasswordEmail {
    let resetURL: String
    
    init(resetURL: String) {
        self.resetURL = resetURL
    }
}

// MARK: - Email
extension ResetPasswordEmail: Email {
    var templateName: String {
        return "reset_password"
    }
    
    var templateData: [String : String] {
        ["reset_url": resetURL]
    }
    
    var subject: String {
        "Reset your password"
    }
}
