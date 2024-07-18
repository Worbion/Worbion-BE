//
//  File.swift
//  
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

protocol AppError: AbortError, DebuggableError {}

protocol BaseError: AppError {
    var userMessage: String? { get }
    var systemMessage: String { get }
    var identifier: String { get }
}
