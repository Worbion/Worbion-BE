//
//  MembershipInfoMail.swift
//
//
//  Created by Cemal on 23.07.2024.
//

import Foundation

// MARK: - MembershipInfoMail
struct MembershipInfoMail {
    let fullname: String
    let username: String
    let emailAddress: String
    let password: String
    let passworsResetRequestUrl: String
    
    init(
        name: String,
        surname: String,
        username: String,
        emailAddress: String,
        password: String,
        passworsResetRequestUrl: String
    ) {
        fullname = name + " " + surname
        self.username = username
        self.emailAddress = emailAddress
        self.password = password
        self.passworsResetRequestUrl = passworsResetRequestUrl
    }
}

// MARK: - MembershipInfoMail
extension MembershipInfoMail: Email {
    var subject: String {
        return "Worbion Hesap Bilgileriniz"
    }
    
    var templateData: [String : String] {
        return [
            "full_name": fullname,
            "username": username,
            "email": emailAddress,
            "password": password,
            "password_reset_request_url": passworsResetRequestUrl
        ]
    }
    
    var templateName: String {
        return "worbion_membership_credentials"
    }
}
