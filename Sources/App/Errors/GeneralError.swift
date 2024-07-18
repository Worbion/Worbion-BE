//
//  GeneralError.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

enum GeneralError: BaseError {
    case generic(userMessage: String?, systemMessage: String, status: HTTPStatus)
    case appVersionIsOutOfDate
}

// MARK: - Error HTTP Status
extension GeneralError {
    var status: HTTPResponseStatus {
        switch self {
        case .generic(_,_, let status):
            return status
        case .appVersionIsOutOfDate:
            return .unauthorized
        }
    }
}

// MARK: - Error User Message
extension GeneralError {
    var identifier: String {
        switch self {
        case .generic:
            return "general.generic_error"
        case .appVersionIsOutOfDate:
            return "general.app_version.out_of_date_error"
        }
    }
}

// MARK: - Error System Message
extension GeneralError {
    var systemMessage: String {
        switch self {
        case .generic(_, let systemMessage,_):
            return systemMessage
        case .appVersionIsOutOfDate:
            return "The client app version is out of dated. Version update required."
        }
    }
}

// MARK: - Error User Message
extension GeneralError {
    var userMessage: String? {
        return nil
    }
}


