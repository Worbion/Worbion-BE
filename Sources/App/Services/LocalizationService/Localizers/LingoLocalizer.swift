//
//  LingoLocalizer.swift
//
//
//  Created by Cemal on 31.08.2024.
//

import Vapor
import Lingo

struct LingoLocalizer {
    let request: Request
}

extension LingoLocalizer: Localizable {
    func localize(key: String, locale: String? = nil, interpolations: [String : Any]?) -> String {
        do {
            let lingo = try request.application.lingoVapor.lingo()
            let lang = locale ?? request.headers.first(name: .acceptLanguage) ?? ""
            let localized = lingo.localize(key, locale: lang, interpolations: interpolations)
            return localized
        }catch {
            request.logger.error("An error occurred during localization")
            return key
        }
    }
}
