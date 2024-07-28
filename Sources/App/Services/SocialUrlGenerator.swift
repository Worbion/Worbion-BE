//
//  SocialUtility.swift
//
//
//  Created by Cemal on 27.07.2024.
//

import Vapor

// MARK: - SocialUtility
struct SocialUtility {
    let socialType: SocialType
    let identifier: String?
}

// MARK: - Private Extension
private extension SocialUtility {
    func generateUrl() -> String? {
        guard let identifier else { return nil }
        
        let urlTemplate = socialType.urlTemplate
        let url = urlTemplate.replacingOccurrences(of: socialType.keyToReplace, with: identifier)
        return url
    }
}

// MARK: - Response Generator
extension SocialUtility {
    var mapResponse: UserSocialResponse {
        let url = generateUrl()
        return .init(socialType: socialType, targetUrl: url)
    }
}

// MARK: - SocialType
enum SocialType: String, Content {
    case instagram = "instagram"
    case tiktok = "tiktok"
    case x = "x"
    
    var urlTemplate: String {
        switch self {
        case .instagram:
            return "https://www.instagram.com/\(keyToReplace)/"
        case .tiktok:
            return "https://www.tiktok.com/@\(keyToReplace)"
        case .x:
            return "https://x.com/\(keyToReplace)"
        }
    }
    
    var keyToReplace: String {
        return "{username}"
    }
}
