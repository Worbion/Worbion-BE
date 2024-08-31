//
//  AttributedTextDTO.swift
//
//
//  Created by Cemal on 31.08.2024.
//

import Vapor

// MARK: - AttributedTextDTO
struct AttributedTextDTO: Content {
    let text: String
    let clickablePartsOfText: [ClickableTextDTO]
}
