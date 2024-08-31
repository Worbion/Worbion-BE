//
//  ClickableTextDTO.swift
//
//
//  Created by Cemal on 25.08.2024.
//

import Vapor

// MARK: - ClickableTextDTO
struct ClickableTextDTO: Content {
    let text: String
    let link: LinkDTO
}
