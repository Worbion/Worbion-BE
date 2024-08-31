//
//  Error+Database.swift
//
//
//  Created by Cemal on 24.08.2024.
//

import Fluent

extension Error {
    var dbError: DatabaseError? {
        return self as? DatabaseError
    }
    
    var isDBConstraintFailureError: Bool {
        guard let dbError else { return false }
        return dbError.isConstraintFailure
    }
}
