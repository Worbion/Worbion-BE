// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Auth-Template",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        // Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // Fluent
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        // Postgres Driver
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.9.2"),
        // JWT
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.2"),
        // Queues
        .package(url: "https://github.com/vapor/queues.git", from: "1.13.0"),
        // Queueus Redis Driver
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.1.1"),
        // Mailgun
        .package(url: "https://github.com/vapor-community/mailgun.git", from: "5.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                .product(name: "Mailgun", package: "mailgun")
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ]
        )
    ]
)
