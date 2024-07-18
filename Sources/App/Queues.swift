//
//  Queues.swift
//
//
//  Created by Cemal on 27.05.2024.
//

import Vapor
import QueuesRedisDriver

func queues(_ app: Application) throws {
    // MARK: Queues Configuration
    if app.environment != .testing {
        try app.queues.use(
            .redis(url:
                Environment.get("REDIS_URL") ?? "redis://127.0.0.1:6379"
            )
        )
    }
    
    // MARK: Jobs
    app.queues.add(EmailJob())
}
