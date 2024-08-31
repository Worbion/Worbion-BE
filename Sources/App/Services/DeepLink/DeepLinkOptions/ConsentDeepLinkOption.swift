//
//  ConsentDeepLinkOption.swift
//
//
//  Created by Cemal on 25.08.2024.
//

import Foundation

// MARK: - ConsentDeepLinkOption
enum ConsentDeepLinkOption {
    case consents
    case consentDetail(type: String)
}

extension ConsentDeepLinkOption: DeepLinkPathGenerateable {
    var rootPath: String {
        return "/consents"
    }
    
    func generateDeepLinkPath() -> String {
        switch self {
        case .consents:
            return rootPath
        case .consentDetail(let type):
            return rootPath + "?type=\(type)"
        }
    }
}
