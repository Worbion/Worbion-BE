//
//  BaseResponse.swift
//  
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

struct BaseResponse<T: Content>: Content {
    var success: Bool = true
    var data: T? = nil
    var error: BaseErrorResponse? = nil
}

extension BaseResponse{
    static func success(data: T? = nil) -> BaseResponse{
        return BaseResponse(data: data)
    }
    
    static func failure(error base: BaseErrorResponse) -> BaseResponse  {
        return .init(success: false, error: base)
    }
}
