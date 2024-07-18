//
//  Services.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor

func services(_ app: Application) throws {
    app.randomGenerators.use(.random)
}
