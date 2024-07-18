//
//  ContentContainer+Extension.swift
//
//
//  Created by Cemal on 28.05.2024.
//

import Vapor

public extension ContentContainer {
    func decodeRequestContent<C: Content>(
        content: C.Type,
        specMessage: String? = nil
    ) throws -> C {
        do {
            let result = try decode(content)
            return result
        }catch {
            let message = specMessage ?? "Required fields missing"
            let error = GeneralError.generic(
                userMessage: nil,
                systemMessage: message,
                status: .badRequest
            )
            throw error
        }
    }
}
