import Vapor
import JWT
import Fluent
import FluentPostgresDriver
import GoogleCloud
import LingoVapor

// configures your application
public func configure(_ app: Application) async throws {
    
    // MARK: - JWT
    if let jwksString = Environment.get("JWKS_String") {
        try app.jwt.signers.use(jwksJSON: jwksString)
    }else {
        fatalError("Failed to load JWKS Keypair file keypair.jwks")
    }
    
    // MARK: - Postgres
    if app.environment == .production {
        if let databaseURL = Environment.get("DATABASE_URL") {
            try app.databases.use(.postgres(url: databaseURL), as: .psql)
        }else {
            app.logger.error("Database URL Not Found")
        }
    }else {
        app.databases.use(
            .postgres(
                hostname: "localhost",
                username: "postgres",
                password: "",
                database: "worbion"
            ),
            as: .psql
        )
    }
    
    app.lingoVapor.configuration = LingoConfiguration(
        defaultLocale: Constants.Language.defaultLocalizationLangKey,
        localizationsDir: Constants.Language.localizationsDIR
    )
    
    app.routes.defaultMaxBodySize = "10mb"
    
    // MARK: Middleware
    app.middleware = .init()
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [
            .accept,
            .authorization,
            .contentType,
            .origin,
            .xRequestedWith,
            .userAgent,
            .accessControlAllowOrigin,
            .accessControlAllowHeaders,
            .accessControlAllowMethods,
            .accessControlRequestMethod,
            
        ]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)
    
    // MARK: Mailgun
    if let mailgunAPIKey = Environment.get("MAILGUN_API_KEY") {
        app.mailgun.configuration = .init(apiKey: mailgunAPIKey)
        app.mailgun.defaultDomain = .worbionDomain
    }
    
    // MARK: App Config
    app.config = .environment
    
    try routes(app)
    try migrations(app)
    try queues(app)
    try services(app)
    try setupStorage(app: app)

    try await app.autoMigrate()
    try app.queues.startInProcessJobs()
    
    try routes(app)
}
