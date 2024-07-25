//
//  Request+Header.swift
//
//
//  Created by Cemal on 25.07.2024.
//

import Vapor

// Get header field by name
extension Request {
    func getHeaderField(by name: String) -> String? {
        return headers.first(name: name)
    }
}

// MARK: Get Client Channel Type
extension Request {
    var clientChannelType: ClientChannelType? {
        guard
            let clientChannelTypeStr = getHeaderField(by: ClientChannelType.customHeaderKey),
            let clientChannelType = Int(clientChannelTypeStr)
        else {
            return nil
        }
        return ClientChannelType(rawValue: clientChannelType)
    }
}
