//
//  BaseErrorResponse.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

struct BaseErrorResponse: Content {
    let systemMessage: String
    let userMessage: String?
    let identifier: String
    
    init(systemMessage: String, userMessage: String? = nil, identifier: String) {
        self.systemMessage = systemMessage
        self.userMessage = userMessage
        self.identifier = identifier
    }
    
    init(error: BaseError) {
        systemMessage = error.systemMessage
        userMessage = error.userMessage
        identifier = error.identifier
    }
}
