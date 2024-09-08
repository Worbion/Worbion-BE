//
//  UserBankAccountRepository.swift
//
//
//  Created by Cemal on 7.09.2024.
//

import Vapor
import Fluent

// MARK: - UserBankAccountRepository
protocol UserBankAccountRepository: Repository {
    typealias UserDatabaseRepository = UserBankAccountRepository & DatabaseRepository
    
    
}

