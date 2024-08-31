//
//  DeepLinkPathGenerateable.swift
//
//
//  Created by Cemal on 25.08.2024.
//

import Foundation

// MARK: - DeepLinkPathGenerateable
protocol DeepLinkPathGenerateable {
    var rootPath: String { get }
    func generateDeepLinkPath() -> String
}
