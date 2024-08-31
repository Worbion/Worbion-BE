//
//  Application+DeepLinkGenerators.swift
//
//
//  Created by Cemal on 25.08.2024.
//

import Vapor

// MARK: - DeepLinkGenerator
struct DeepLinkGenerator: DeepLinkGenerateable {
    var host: String
}

// MARK: - DeepLinkGenerator + Application
extension Application {
    var defaultDeepLinkGenerator: DeepLinkGenerateable {
        let wbDeepLink = config.deeplinkUrl
        return DeepLinkGenerator(host: wbDeepLink)
    }
}

// MARK: - DeepLinkGenerator + Request
extension Request {
    var defaultDeepLinkGenerator: DeepLinkGenerateable {
        return application.defaultDeepLinkGenerator
    }
}
