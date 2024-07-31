//
//  Migrations.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

func migrations(_ app: Application) throws {
    // Initial Migrations
    app.migrations.add(CreateUserEntity())
    app.migrations.add(CreateRefreshTokenEntity())
    app.migrations.add(CreateEmailTokenEntity())
    app.migrations.add(CreatePasswordTokenEntity())
    app.migrations.add(CreateConsentEntity())
    app.migrations.add(CreateConsentVersionEntity())
    app.migrations.add(CreateDeviceEntity())
    app.migrations.add(CreateBankEntity())
    app.migrations.add(CreateUserBankAccountEntity())
}

