//
//  Request+Header.swift
//
//
//  Created by Cemal on 25.07.2024.
//

import Vapor

// Get header field by name
extension Request {
    func getCustomHeaderField(by name: CustomHeaderKeyType) -> String? {
        return headers.first(name: name.rawValue)
    }
}

// MARK: Get Client Channel Type
extension Request {
    var clientChannelType: ClientChannelType? {
        guard
            let clientChannelTypeStr = getCustomHeaderField(by: .channelType),
            let clientChannelType = Int(clientChannelTypeStr)
        else {
            return nil
        }
        return ClientChannelType(rawValue: clientChannelType)
    }
}
