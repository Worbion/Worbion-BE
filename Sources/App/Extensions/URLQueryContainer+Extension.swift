//
//  URLQueryContainer+Extension.swift
//
//
//  Created by Cemal on 28.05.2024.
//

import Vapor

public extension URLQueryContainer {
    func get<D: Decodable>(
        decodableType: D.Type = D.self,
        at path: CodingKeyRepresentable...,
        specMessage: String? = nil
    ) throws -> D {
        do {
            let result = try get(decodableType, at: path)
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
