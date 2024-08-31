//
//  Request+Localizable.swift
//
//
//  Created by Cemal on 31.08.2024.
//

import Vapor
import LingoVapor

extension Request {
    var localization: Localizable {
        return LingoLocalizer(request: self)
    }
}
