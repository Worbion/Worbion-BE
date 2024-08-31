//
//  DeepLinkGenerateable.swift
//
//
//  Created by Cemal on 25.08.2024.
//

import Foundation

// MARK: - DeepLinkGenerateable
protocol DeepLinkGenerateable {
    var host: String { get }
    func generate(option generatable: DeepLinkPathGenerateable) -> String
}

extension DeepLinkGenerateable {
    func generate(option generatable: DeepLinkPathGenerateable) -> String {
        return host + generatable.generateDeepLinkPath()
    }
}
