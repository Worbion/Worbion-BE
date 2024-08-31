//
//  LinkDTO.swift
//
//
//  Created by Cemal on 25.08.2024.
//

import Vapor

// MARK: - LinkDTO
struct LinkDTO: Content {
    let url: String
    let openType: LinkOpenTypeDTO
}

// MARK: - LinkOpenTypeDTO
enum LinkOpenTypeDTO: String, Content {
    case deepLink = "DEEPLINK"
    case insideApp = "APP"
    case atBrowser = "BROWSER"
}
