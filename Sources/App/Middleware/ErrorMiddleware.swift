//
//  ErrorMiddleware.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

/// Captures all errors and transforms them into an internal server error HTTP response.
public final class ErrorMiddleware: Middleware {
    public static func `default`(environment: Environment) -> ErrorMiddleware {
        return .init { req, error in
            // variables to determine
            let status: HTTPResponseStatus
            let headers: HTTPHeaders

            // inspect the error type
            switch error {
            case let abort as AbortError:
                // this is an abort error, we should use its status, reason, and headers
                status = abort.status
                headers = abort.headers
            default:
                // if not release mode, and error is debuggable, provide debug info
                // otherwise, deliver a generic 500 to avoid exposing any sensitive error info
                status = .internalServerError
                headers = [:]
            }
            
            // Report the error to logger.
            req.logger.report(error: error)
            
            // create a Response with appropriate status
            let response = Response(status: status, headers: headers)
            
            // attempt to serialize the error to json
            do {
                let baseError = (error as? BaseError) ?? GeneralError.generic(userMessage: nil, systemMessage: error.localizedDescription, status: .internalServerError)
                
                let localization = req.localization
                
                var localizedUserMessage: String? = nil
                
                if let userMessage = baseError.userMessage {
                    localizedUserMessage = localization.localize(key: userMessage)
                }
                
                let baseErrorResponse = BaseErrorResponse(
                    systemMessage: baseError.systemMessage,
                    userMessage: localizedUserMessage,
                    identifier: baseError.identifier
                )
                
                let errorResponse = BaseResponse<BaseEmptyResponse>.failure(error: baseErrorResponse)
                response.body = try .init(data: JSONEncoder().encode(errorResponse), byteBufferAllocator: req.byteBufferAllocator)
                response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                response.body = .init(string: "Oops: \(error)", byteBufferAllocator: req.byteBufferAllocator)
                response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return response
        }
    }

    /// Error-handling closure.
    private let closure: (@Sendable (Request, Error) -> (Response))

    /// Create a new `ErrorMiddleware`.
    ///
    /// - parameters:
    ///     - closure: Error-handling closure. Converts `Error` to `Response`.
    public init(_ closure: @Sendable @escaping (Request, Error) -> (Response)) {
        self.closure = closure
    }
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).flatMapErrorThrowing { error in
            return self.closure(request, error)
        }
    }
}

