//
//  Localizable.swift
//
//
//  Created by Cemal on 31.08.2024.
//

import Vapor

protocol Localizable {
    func localize(key: String) -> String
    func localize(key: String, locale: String?) -> String
    func localize(key: String, locale: String?, interpolations: [String: Any]?) -> String
}

extension Localizable {
    func localize(key: String) -> String {
        return localize(key: key, locale: nil, interpolations: nil)
    }
    
    func localize(key: String, locale: String?) -> String {
        return localize(key: key, locale: locale, interpolations: nil)
    }
}
