//
//  ClientChannelType.swift
//
//
//  Created by Cemal on 25.07.2024.
//

import Foundation

// MARK: - ClientChannelType
enum ClientChannelType: Int {
    case clientMobile = 0
    case clientWeb = 1
    case panelWeb = 2
}

// MARK: - ClientChannelType
extension ClientChannelType: CustomHeaderKeyable {
    static var customHeaderKey: CustomHeaderKeyType {
        return .channelType
    }
}
