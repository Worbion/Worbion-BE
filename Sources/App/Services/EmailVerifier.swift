import Vapor
import Queues
import Fluent

struct EmailVerifier {
    let config: AppConfig
    let queue: Queue
    let generator: RandomGenerator
    let db: Database
    
    func verify(for user: UserEntity) async throws {
        let token = generator.generate(bits: 256)
        let emailToken = try EmailTokenEntity(userID: user.requireID(), token: SHA256.hash(token))
        let verifyUrl = url(token: token)
        try await emailToken.create(on: db)
        try await queue.dispatch(EmailJob.self, .init(VerificationEmail(verifyUrl: verifyUrl), to: user.email))
    }
    
    private func url(token: String) -> String {
        #"\#(config.apiURL)/auth/email-verification?token=\#(token)"#
    }
}

// MARK: - Application + EmailVerifier
extension Application {
    var emailVerifier: EmailVerifier {
        return EmailVerifier(
            config: config,
            queue: queues.queue,
            generator: random,
            db: db
        )
    }
}

// MARK: - Request + EmailVerifier
extension Request {
    var emailVerifier: EmailVerifier {
        return EmailVerifier(
            config: application.config,
            queue: queue,
            generator: application.random,
            db: db
        )
    }
}

