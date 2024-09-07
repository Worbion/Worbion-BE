//
//  Error+Database.swift
//
//
//  Created by Cemal on 24.08.2024.
//

import Fluent
import PostgresNIO

extension Error {
    var dbError: DatabaseError? {
        return self as? DatabaseError
    }
    
    var isDBConstraintFailureError: Bool {
        guard let dbError else { return false }
        return dbError.isConstraintFailure
    }
    
    var failedConstraintDescription: String? {
        guard isDBConstraintFailureError,
              let psqlError = (self as? PSQLError) else { return nil }
        return psqlError.serverInfo?[.detail]
    }
}
